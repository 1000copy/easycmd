
{"lang:pascal TNetconnection" BY GOOGLE CODE SEARCH}

{-------------------------------------------------------------------------------
	Network Connection Mangager
	Copyright (c) 1996 Ryan P. Cote
	Digital Insight

	75040.2640@compuserve.com

	The code herein is released to public domain.  You are free to use it
	or modify it as you choose.  You may redistribute this code under the
	following conditions:
		1. You must distribute all of its original files.
		2. Each file must be in its original condition.
		3. You may not profit from the redistribution of this component as a
			 component, part of another component, or part of a component package
			 without the written permission of Ryan P. Cote.

	Digital Insight or Ryan Cote gives no warrenty to the accuracy, fitness
	for particular use, effects of use, or reliability of the code containted
	herein.

--------------------------------------------------------------------------------
	Purpose:
		This component manages connections to network resources in Windows 95
		and NT.  You may establish connections, map local resources (drives and
		ports) to network resources, and you may break connections with this
		component.

		This component is essentially a wrapper for the Win32 API functions
		WNetAddConnection2 and WNetCancelConnection2.

	System Requirements:
		Delphi 2.0 or higher
		Windows 95 or Windows NT
		Installed network protocol
		Available network disk or print resources

	Installation:
		Copy the source file (NetConn.pas) and the component resource (NetConn.dcr)
		to a directory included in the Delphi Library Search Path (found in the
		Install Components dialog box).  Select Component\Install from the Delphi
		menu.

	Properties:
		UserName - String containing User ID used to establish connections with
		with remote servers

		Password - String containing Password used with UserName

		ResourceType - rtDisk for Disk type resources, rtPrint for Printer type
		resources, and rtAny for any type resources.  May only be rtAny if property
		LocalName is not specified (raises EParameterError when violated).

		LocalName - String containing name of local resource to map to network
		resource specified in property RemoteName. Example values are "F:" or
		"LPT2" (without the quotes). May not be specified when ResourceType is
		rtAny (raises EParameterError when violated).

		RemoteName - String containing name of remote network resource to connect
		to.  Uses UNC (universal naming convention) which is in the format of
		"\\ServerName\ResourceName" (without the quotes).  For example, the SYS
		volume of a Netware server named CENTRAL would be specified as
		"\\CENTRAL\SYS" (without the quotes).

		ReconnectAtLogon - Boolean value that is true when you want Windows to
		automatically attempt to reconnect to the specified resource each time you
		log in.  A local resource must be specified in order for automatic
		reconnection (raises EParameterError on violation).

		Provider - String that specifies the network provider to connect to.  Use
		this parameter only if you know for sure the provider you want to use.
		Otherwise, leave this field blank and let the operating system determine
		the provider for you.

	Methods:
		Connect - Takes no parameters.  Attempts to connect to resource.  Raises
		an EConnectError exception if the function fails.

		Disconnect - Takes one boolean parameter that tells whether or not to force
		disconnection when files are open on resource (True to force).  If the
		LocalName property is set, it attempts to disconnect the resource connected
		to that device.  Otherwise, it attempts to disconnect from the resouce
		specified by the RemoteName property.



-------------------------------------------------------------------------------}
unit NetConn;

interface

uses
	Windows, Messages, Classes, SysUtils;

type
	TResourceTypes = (rtDisk, rtPrint, rtAny);

	EParameterError = class(Exception);
	EConnectError = class(Exception);
	EDisconnectError = class(Exception);

	TNetConnection = class(TComponent)
  private
		{ Private declarations }
		FUserName: string;
		FPassword: string;
		FResourceType: TResourceTypes;
		FLocalName: string;
		FRemoteName: string;
		FReconnectAtLogon: boolean;
		FProvider: string;
		procedure SetResourceType(AType: TResourceTypes);
		procedure SetLocalName(AName: string);
		procedure SetReconnectAtLogon(AReconnect: boolean);
		function GetErrorMessage(AErrorNum: DWORD): string;
	protected
    { Protected declarations }
  public
		{ Public declarations }
		function Connect:Boolean;
		procedure Disconnect(AForce: boolean);
	published
		{ Published declarations }
		property UserName: string read FUserName write FUserName;
		property Password: string read FPassword write FPassword;
		property ResourceType: TResourceTypes read FResourceType
				write SetResourceType default rtAny;
		property LocalName: string read FLocalName write SetLocalName;
		property RemoteName: string read FRemoteName write FRemoteName;
		property ReconnectAtLogon: boolean read FReconnectAtLogon
				write SetReconnectAtLogon default False;
		property Provider: string read FProvider write FProvider;
	end;

procedure Register;

implementation

procedure Register;
begin
	RegisterComponents('System', [TNetConnection]);
end;

procedure TNetConnection.SetResourceType(AType: TResourceTypes);
begin
	if (AType = rtAny) and (Trim(FLocalName) <> '') then
		raise EParameterError.Create('Cannot be rtAny when LocalName is set')
	else
		FResourceType := AType;
end;

procedure TNetConnection.SetLocalName(AName: string);
begin
	if Trim(AName) = '' then
		FReconnectAtLogon := false
	else
		if (FResourceType = rtAny) then
			raise EParameterError.Create('Cannot be set when ResourseType is rtAny');

	FLocalName := AName;
end;

procedure TNetConnection.SetReconnectAtLogon(AReconnect: boolean);
begin
	if (AReconnect = True) and (Trim(FLocalName) = '') then
		raise EParameterError.Create('No local resource assigned')
	else
		FReconnectAtLogon := AReconnect;
end;

function TNetConnection.Connect:Boolean;
var
	NetResource: TNetResource;
	dwFlags: DWORD;
begin
  Result := false ;
	case FResourceType of
		rtAny: NetResource.dwType := RESOURCETYPE_ANY;
		rtDisk: NetResource.dwType := RESOURCETYPE_DISK;
		rtPrint: NetResource.dwType := RESOURCETYPE_PRINT;
	end;
	NetResource.lpLocalName := PChar(FLocalName);
	NetResource.lpRemoteName := PChar(FRemoteName);
	NetResource.lpProvider := PChar(FProvider);
	if FReconnectAtLogon then
		dwFlags := CONNECT_UPDATE_PROFILE
	else
		dwFlags := 0;

	if WNetAddConnection2(NetResource, PChar(FPassword), PChar(FUserName),
			dwFlags) <> NO_ERROR then
		raise EConnectError.Create('ERROR: ' + GetErrorMessage(GetLastError()))
  else
    Result := true;
end;

procedure TNetConnection.Disconnect(AForce: boolean);
var
	strDevice: string;
begin
	if Trim(FLocalName) <> '' then
		strDevice := FLocalName
	else
		strDevice := FRemoteName;

	if WNetCancelConnection2(PChar(strDevice), CONNECT_UPDATE_PROFILE, AForce)
			<> NO_ERROR then
		raise EDisconnectError.Create('ERROR: ' + GetErrorMessage(GetLastError()));
end;

function TNetConnection.GetErrorMessage(AErrorNum: DWORD): string;
begin
	case AErrorNum of
		ERROR_ACCESS_DENIED:
			Result := 'Access to network resource denied';
		ERROR_ALREADY_ASSIGNED:
			Result := 'Local device already assigned';
		ERROR_BAD_DEV_TYPE:
			Result := 'Local device type does not match network resource type';
		ERROR_BAD_DEVICE:
			Result := 'Local device is invalid';
		ERROR_BAD_NET_NAME:
			Result := 'Network resource name is invalid or unlocatable';
		ERROR_BAD_NETPATH:
			Result := 'Network path not found';
		ERROR_BAD_PROFILE:
			Result := 'User profile is in an incorrect format';
		ERROR_BAD_PROVIDER:
			Result := 'Provider property does not match any provider';
		ERROR_BUSY:
			Result := 'Provider is busy';
		ERROR_CANCELLED:
			Result := 'Connection attempt cancelled';
		ERROR_CANNOT_OPEN_PROFILE:
			Result := 'Cannot save reconnect at logon information';
		ERROR_DEVICE_ALREADY_REMEMBERED:
			Result := 'Connection already remembered';
		ERROR_DEVICE_IN_USE:
			Result := 'Device in use by active process, cannot disconnect';
		ERROR_EXTENDED_ERROR:
			Result := 'A network specific error occurred';
		ERROR_INVALID_PASSWORD:
			Result := 'Invalid password';
		ERROR_NO_NET_OR_BAD_PATH:
			Result := 'Network not started or name could not be handled';
		ERROR_NO_NETWORK:
			Result := 'No network present';
		ERROR_NOT_CONNECTED:
			Result := 'Not connected to specified resource or on specified device';
		ERROR_OPEN_FILES:
			Result := 'Files are open on resource and force disconnect not specified';
		ERROR_LOGON_FAILURE:
			Result := 'User name or password incorrect';
    1219:
			Result := 'incorrect credential';
		else
			Result := IntToStr(AErrorNum) + ': Unhandled Error';
	end;
end;

end.
