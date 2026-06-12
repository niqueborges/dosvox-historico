{---------------------------------------------------------------}
{
{    Verificador de Redes Wifi
{
{    Autor: Antonio Borges
{
{    Baseado em vários programas similares baseados na WlanAPI
{
{    Em 27/01/2014
{
{---------------------------------------------------------------}

program detectaWifi;

{$R-}

uses dvwin, dvcrt, Windows, SysUtils,
     nduWlanAPI, nduWlanTypes;

{$R-}

const
    WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES =$00000001;

var
    hClient: THandle;

function DOT11_AUTH_ALGORITHM_To_String(Dummy :Tndu_DOT11_AUTH_ALGORITHM):String;
begin
    Result:='';
    case Dummy of
        DOT11_AUTH_ALGO_80211_OPEN          : Result:= '80211_OPEN';
        DOT11_AUTH_ALGO_80211_SHARED_KEY    : Result:= '80211_SHARED_KEY';
        DOT11_AUTH_ALGO_WPA                 : Result:= 'WPA';
        DOT11_AUTH_ALGO_WPA_PSK             : Result:= 'WPA_PSK';
        DOT11_AUTH_ALGO_WPA_NONE            : Result:= 'WPA_NONE';
        DOT11_AUTH_ALGO_RSNA                : Result:= 'RSNA';
        DOT11_AUTH_ALGO_RSNA_PSK            : Result:= 'RSNA_PSK';
        DOT11_AUTH_ALGO_IHV_START           : Result:= 'IHV_START';
        DOT11_AUTH_ALGO_IHV_END             : Result:= 'IHV_END';
    end;
End;

function DOT11_CIPHER_ALGORITHM_To_String( Dummy :Tndu_DOT11_CIPHER_ALGORITHM):String;
Begin
    Result:='';
    case Dummy of
    DOT11_CIPHER_ALGO_NONE      : Result:= 'NONE';
    DOT11_CIPHER_ALGO_WEP40     : Result:= 'WEP40';
    DOT11_CIPHER_ALGO_TKIP      : Result:= 'TKIP';
    DOT11_CIPHER_ALGO_CCMP      : Result:= 'CCMP';
    DOT11_CIPHER_ALGO_WEP104    : Result:= 'WEP104';
    DOT11_CIPHER_ALGO_WPA_USE_GROUP : Result:= 'WPA_USE_GROUP OR RSN_USE_GROUP';
    //DOT11_CIPHER_ALGO_RSN_USE_GROUP : Result:= 'RSN_USE_GROUP';
    DOT11_CIPHER_ALGO_WEP           : Result:= 'WEP';
    DOT11_CIPHER_ALGO_IHV_START     : Result:= 'IHV_START';
    DOT11_CIPHER_ALGO_IHV_END       : Result:= 'IHV_END';
    end;
End;

procedure inicializa;
begin
    sintInic (0, '');
    sintWriteln ('Detector de redes WIFI - v 1.0');
    writeln ('Por José Antonio Borges - Projeto DOSVOX');
    writeln;

    hClient := 0;
end;

procedure finaliza;
begin
    if hClient <> 0 then
        WlanCloseHandle(hClient, nil);
    sintWriteln ('Fim da varredura de redes');
    sintFim;
    readln;
end;


procedure mostraRedePrincipal(pInterface: Pndu_WLAN_INTERFACE_INFO_LIST;
                              nInter: integer);
var
    pInterfaceGuid: PGUID;
    ResultInt: integer;
    pdwDataSize: DWORD;
    RSSI: integer;
    ppData: pndu_WLAN_CONNECTION_ATTRIBUTES;


begin
    ppData:=nil;
    pdwDataSize:=0;

    pInterfaceGuid:= @pInterface^.InterfaceInfo[nInter].InterfaceGuid;

    ResultInt:=WlanQueryInterface(hClient, pInterfaceGuid,
               wlan_intf_opcode_current_connection, nil, @pdwDataSize, @ppData,nil);
    try
      if (ResultInt=ERROR_SUCCESS) and
         (pdwDataSize=SizeOf(Tndu_WLAN_CONNECTION_ATTRIBUTES)) then
      begin
        sintWriteln('Rede principal: Profile ' + ppData^.strProfileName);

        with ppData^.wlanAssociationAttributes do
            sintWriteln(Format('Mac Address %.2x:%.2x:%.2x:%.2x:%.2x:%.2x',[
                     dot11Bssid[0], dot11Bssid[1],dot11Bssid[2],
                     dot11Bssid[3],dot11Bssid[4], dot11Bssid[5]]));
        RSSI := (ppData^.wlanAssociationAttributes.wlanSignalQuality div 2) - 100;
        sintWriteln('RSSI ' + intToStr(RSSI) + ' dbm');
      end;
    finally
      if ppData<>nil then
       WlanFreeMemory(ppData);
    end;
    writeln;
end;

procedure mostraRede (pAvailableNetworkList: Pndu_WLAN_AVAILABLE_NETWORK_LIST;
                      nRede: integer);
begin
    with pAvailableNetworkList^.Network[nRede] do
        begin
           sintWriteln ('Rede ' + intToStr(nRede));

           if bSecurityEnabled then
               sintWriteln ('Rede segura')
           else
               sintWriteln ('Rede aberta');

           if strProfileName <> '' then
               sintWriteln ('Profile: ' + strProfileName);

           sintWriteln ('Nome: ' + PChar(@dot11Ssid.ucSSID));

           sintWriteln ('Sinal: ' +
                     intToStr(wlanSignalQuality) + '%');

           sintWriteln ('Algoritmos: ' +
                     DOT11_AUTH_ALGORITHM_To_String(dot11DefaultAuthAlgorithm) +  ' ' +
                     DOT11_CIPHER_ALGORITHM_To_String(dot11DefaultCipherAlgorithm));
        end;
end;

procedure folheiaRedes (pInterface: Pndu_WLAN_INTERFACE_INFO_LIST; nInter: integer);
var
    n: Integer;
    pAvailableNetworkList: Pndu_WLAN_AVAILABLE_NETWORK_LIST;
    pInterfaceGuid: PGUID;

begin
    pInterfaceGuid:= @pInterface^.InterfaceInfo[nInter].InterfaceGuid;
                // originalmente pInterface^.dwIndex mas seria ninter?

    if WlanGetAvailableNetworkList(hClient, pInterfaceGuid,
            WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES, nil,
            pAvailableNetworkList) <> ERROR_SUCCESS then
        begin
            sintWriteLn('Erro obtendo a lista de redes: ' + intToStr(nInter));
            exit;
        end;

    limpaBufTec;
    sintWriteln ('Interface: ' + intToStr (nInter) + ' com ' +
               intToStr(pAvailableNetworkList^.dwNumberOfItems) + ' redes');
    writeln;

    for n := 0 to pAvailableNetworkList^.dwNumberOfItems - 1 do
        begin
            mostraRede (pAvailableNetworkList, n);
            //writeln;
            readln;
        end;
end;

function descobreInterfaces: Pndu_WLAN_INTERFACE_INFO_LIST;
var
    dwVersion: DWORD;
    pInterface: Pndu_WLAN_INTERFACE_INFO_LIST;

begin
    result := NIL;
    if WlanOpenHandle(1, nil, @dwVersion, @hClient) <> ERROR_SUCCESS then
        begin
            sintWriteLn('Não foi possível abrir a interface de redes móveis');
            exit;
        end;

    if WlanEnumInterfaces(hClient, nil, @pInterface) <> ERROR_SUCCESS then
        begin
            sintWriteln('Erro ao enumerar as interfaces de rede Wifi');
            exit;
        end;

    result := pInterface;
end;

var i: integer;
    nInterfaces: integer;
    pInterface: Pndu_WLAN_INTERFACE_INFO_LIST;

begin
    inicializa;

    pInterface := descobreInterfaces();
    if pInterface <> NIL then
        begin
            nInterfaces := pInterface^.dwNumberOfItems;
            sintWriteln ('Número de interfaces de rede: ' + intToStr(nInterfaces));
        end
    else
        nInterfaces := 0;

    for i := 0 to nInterfaces - 1 do
        with pInterface^.InterfaceInfo[i] do
            begin
                sintWriteln('Interface ' + strInterfaceDescription);
                writeLn('GUID      ' + GUIDToString(InterfaceGuid));
                writeln;

               mostraRedePrincipal(pInterface, i);
               folheiaRedes(pInterface, i);
            end;

    finaliza;
end.



















procedure Scan();
var
    hClient: THandle;
    dwVersion: DWORD;
    ResultInt: DWORD;
    pInterface: Pndu_WLAN_INTERFACE_INFO_LIST;
    pInterfaceGuid: TGUID;
    pdwDataSize, RSSI: DWORD;
    ppData: pndu_WLAN_CONNECTION_ATTRIBUTES;
    i: Integer;





  for i := 0 to pInterface^.dwNumberOfItems - 1 do
  begin
    Writeln('Interface  ' + pInterface^.InterfaceInfo[i].strInterfaceDescription);
    WriteLn('GUID       ' + GUIDToString(pInterface^.InterfaceInfo[i].InterfaceGuid));
    pInterfaceGuid:= pInterface^.InterfaceInfo[pInterface^.dwIndex].InterfaceGuid;

    ppData:=nil;
    pdwDataSize:=0;
    ResultInt:=WlanQueryInterface(hClient, @pInterfaceGuid, wlan_intf_opcode_current_connection, nil, @pdwDataSize, @ppData,nil);
    try
      if (ResultInt=ERROR_SUCCESS) and (pdwDataSize=SizeOf(Tndu_WLAN_CONNECTION_ATTRIBUTES)) then
      begin
        Writeln(Format('Profile %s',[ppData^.strProfileName]));
        Writeln(Format('Mac Address %.2x:%.2x:%.2x:%.2x:%.2x:%.2x',[
        ppData^.wlanAssociationAttributes.dot11Bssid[0],
        ppData^.wlanAssociationAttributes.dot11Bssid[1],
        ppData^.wlanAssociationAttributes.dot11Bssid[2],
        ppData^.wlanAssociationAttributes.dot11Bssid[3],
        ppData^.wlanAssociationAttributes.dot11Bssid[4],
        ppData^.wlanAssociationAttributes.dot11Bssid[5]]));
        RSSI := (ppData^.wlanAssociationAttributes.wlanSignalQuality div 2) - 100;
        Writeln(Format('RSSI %d dbm',[RSSI]));
      end;
    finally
      if ppData<>nil then
       WlanFreeMemory(ppData);
    end;
  end;
 finally
  WlanCloseHandle(hClient, nil);
 end;
end;

begin
  try
    Scan();
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Readln;
end.




begin
  try
    Scan();
    Readln;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.




	/* Client opens a handle for connection */
	status = WlanOpenHandle( WLAN_API_VERSION, NULL, &dwCurVersion,&hClient );

	/* Get the list of wi-fi interfaces */
	status = WlanEnumInterfaces(hClient, NULL, &pIfList);

    pIfInfo = (WLAN_INTERFACE_INFO *) &pIfList->InterfaceInfo[0];


	/* Get the list of visible networks */
		status = WlanGetAvailableNetworkList (hClient,&pIfInfo->InterfaceGuid,0,NULL,&pBssList);

		for (tmploop = 0; tmploop < pBssList->dwNumberOfItems; tmploop++)
		{
			pBssEntry = (WLAN_AVAILABLE_NETWORK *) & pBssList->Network[tmploop];
			if (pBssEntry->dot11Ssid.uSSIDLength != 0)
			{

				strcpy(tmpBuffer,(char *) pBssEntry->dot11Ssid.ucSSID );

				/* Whether the HOST to be connected is found ? */
				if(strcmp(tmpBuffer,"2WIRE472") == 0)
				{
					//hostFoundflag = SET;
					wlanConnPara.wlanConnectionMode = wlan_connection_mode_discovery_secure;//wlan_connection_mode_discovery_unsecure;
					wlanConnPara.strProfile = pBssEntry->strProfileName;
					strcpy( (char *)(infoForSSID.ucSSID), tmpBuffer);
					infoForSSID.uSSIDLength = pBssEntry->dot11Ssid.uSSIDLength;
					wlanConnPara.pDot11Ssid =&infoForSSID;
					wlanConnPara.pDesiredBssidList = NULL;
					wlanConnPara.dot11BssType = pBssEntry->dot11BssType;
					wlanConnPara.dwFlags = pBssEntry->dwFlags;

					/* Connect to the host */
					status = WlanConnect( hClient, &pIfInfo->InterfaceGuid, &wlanConnPara, NULL );

				}
			}
		}
