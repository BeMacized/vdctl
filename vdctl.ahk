#SingleInstance force
#Include AHKsock.ahk
Connect()
Return

global Connected := false
global SocketId := -1

#1::Send("d1")
#2::Send("d2")
#3::Send("d3")
#4::Send("d4")
#5::Send("d5")
#6::Send("d6")
#7::Send("d7")
#8::Send("d8")
#9::Send("d9")
#0::Send("d10")
#+1::Send("m1")
#+2::Send("m2")
#+3::Send("m3")
#+4::Send("m4")
#+5::Send("m5")
#+6::Send("m6")
#+7::Send("m7")
#+8::Send("m8")
#+9::Send("m9")
#+0::Send("m10")

Connect()
{
    if (i := AHKsock_Connect("localhost", 27015, "Receive")) {
        OutputDebug, % "AHKsock_Connect() failed with return value = " i " and ErrorLevel = " ErrorLevel " Retrying..."
        Sleep, 1000
        Connect()
    }
}

Receive(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0)
{
    if (sEvent = "CONNECTED") {
        if (_iSocket = -1) {
            global Connected := false
            OutputDebug, % "Client - AHKsock_Connect() failed. Retrying..."
            Sleep, 1000
            Connect()
        } else {
            OutputDebug, % "Client - AHKsock_Connect() successfully connected!"
            global Connected := true
            global SocketId := iSocket
        }
    } else if (sEvent = "DISCONNECTED") {
        global Connected := false
        OutputDebug, % "Client - The server closed the connection. Retrying..."
        Sleep, 1000
        Connect()
    } else if (sEvent = "RECEIVED") {
        OutputDebug, % "Client - We received " iLength " bytes."
        OutputDebug, % "Client - Data: " Bin2Hex(&bData, iLength)
    }
}

Send(Text)
{
    if (!Connected) Return
    OutputDebug, % "Sending " Text
    if (i := AHKsock_ForceSend(global SocketId, &Text, StrLen(Text) * 2)) {
        OutputDebug, % "AHKsock_ForceSend failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
    }
}

Bin2Hex(addr, len)
{
    Static fun, ptr
    if (fun = "") {
        if A_IsUnicode
            if (A_PtrSize = 8)
        h=4533c94c8bd14585c07e63458bd86690440fb60248ffc2418bc9410fb6c0c0e8043c090fb6c00f97c14180e00f66f7d96683e1076603c8410fb6c06683c1304180f8096641890a418bc90f97c166f7d94983c2046683e1076603c86683c13049ffcb6641894afe75a76645890ac366448909c3
        Else h=558B6C241085ED7E5F568B74240C578B7C24148A078AC8C0E90447BA090000003AD11BD2F7DA66F7DA0FB6C96683E2076603D16683C230668916240FB2093AD01BC9F7D966F7D96683E1070FB6D06603CA6683C13066894E0283C6044D75B433C05F6689065E5DC38B54240833C966890A5DC3
        Else h=558B6C241085ED7E45568B74240C578B7C24148A078AC8C0E9044780F9090F97C2F6DA80E20702D1240F80C2303C090F97C1F6D980E10702C880C1308816884E0183C6024D75CC5FC606005E5DC38B542408C602005DC3
        VarSetCapacity(fun, StrLen(h) // 2)
        Loop % StrLen(h) // 2
        NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
        ptr := A_PtrSize ? "Ptr" : "UInt"
        DllCall("VirtualProtect", ptr, &fun, ptr, VarSetCapacity(fun), "UInt", 0x40, "UInt*", 0)
    }
    VarSetCapacity(hex, A_IsUnicode ? 4 * len + 2 : 2 * len + 1)
    DllCall(&fun, ptr, &hex, ptr, addr, "UInt", len, "CDecl")
    VarSetCapacity(hex, -1) ; update StrLen
    Return hex
}