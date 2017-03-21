Public Class Form1

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Shell(System.IO.Path.GetDirectoryName(Application.ExecutablePath) & "\bin\splash.exe", AppWinStyle.NormalNoFocus)
        Shell(System.IO.Path.GetDirectoryName(Application.ExecutablePath) & "\bin\adl.exe " & "bin\Main-app.xml", AppWinStyle.Hide)

        Me.Close()
    End Sub
End Class
