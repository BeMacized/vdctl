using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Windows;
using WindowsDesktop;

namespace vdctl
{
    public partial class MainWindow : Window
    {
        TcpListener server = null;

        public MainWindow()
        {
            InitializeComponent();
            InitServer();
        }

        private void processCommand(string command)
        {
            char[] chars = command.ToCharArray();
            switch (chars[0])
            {
                case 'd':
                {
                    int index = int.Parse(command.Substring(1)) - 1;
                    VirtualDesktop.GetDesktops()[index].Switch();
                    break;
                }
                case 'm':
                {
                    int index = int.Parse(command.Substring(1)) - 1;
                    VirtualDesktopHelper.MoveToDesktop(GetForegroundWindow(), VirtualDesktop.GetDesktops()[index]);
                    break;
                }
            }
        }

        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();

        private void InitServer()
        {
            try
            {
                Int32 port = 27015;
                IPAddress localAddr = IPAddress.Parse("127.0.0.1");
                server = new TcpListener(localAddr, port);
                server.Start();
                Byte[] bytes = new Byte[256];
                String data = null;
                while (true)
                {
                    try
                    {
                        Console.Write("Waiting for a connection... ");
                        TcpClient client = server.AcceptTcpClient();
                        Console.WriteLine("Connected!");
                        data = null;
                        NetworkStream stream = client.GetStream();
                        while (true)
                        {
                            int i;
                            while ((i = stream.Read(bytes, 0, bytes.Length)) != 0)
                            {
                                data = System.Text.Encoding.Unicode.GetString(bytes, 0, i);
                                processCommand(data);
                            }
                        }
                    }
                    catch (IOException e)
                    {
                        // We don't care about disconnects
                    }
                }
            }
            catch (SocketException e)
            {
                Console.WriteLine("SocketException: {0}", e);
                Environment.Exit(1);
            }
            finally
            {
                // Stop listening for new clients.
                server.Stop();
            }
        }
    }
}