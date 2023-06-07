Set objArgs = WScript.Arguments
username = objArgs(0)

Set objVoice = CreateObject("SAPI.SpVoice")
objVoice.Speak "Welcome " & username