#include <windows.h>
#include <iostream>
#include <fstream>

bool aDown = false;
bool dDown = false;

void WriteCommand(const char* cmd) {
    std::ofstream f("C:\\temp\\evade_cmd.txt");
    f << cmd;
    f.close();
}

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    static DWORD lastMoveTime = 0;

    if (uMsg == WM_INPUT)
    {
        UINT dwSize = 0;
        GetRawInputData((HRAWINPUT)lParam, RID_INPUT, NULL, &dwSize, sizeof(RAWINPUTHEADER));
        LPBYTE lpb = new BYTE[dwSize];
        if (GetRawInputData((HRAWINPUT)lParam, RID_INPUT, lpb, &dwSize, sizeof(RAWINPUTHEADER)) == dwSize)
        {
            RAWINPUT* raw = (RAWINPUT*)lpb;
            if (raw->header.dwType == RIM_TYPEMOUSE)
            {
                LONG dx = raw->data.mouse.lLastX;

                if (dx < 0) {
                    WriteCommand("A");
                    lastMoveTime = GetTickCount();
                }
                else if (dx > 0) {
                    WriteCommand("D");
                    lastMoveTime = GetTickCount();
                }
                else {
                    WriteCommand("NONE");
                }
            }
        }
        delete[] lpb;
        return 0;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

int main()
{
    CreateDirectoryA("C:\\temp", NULL);

    const wchar_t CLASS_NAME[] = L"RawInputWindowClass";
    WNDCLASS wc = {};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = CLASS_NAME;
    RegisterClass(&wc);

    HWND hwnd = CreateWindowEx(
        0, CLASS_NAME, L"Raw Input Mouse Delta",
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 300, 200,
        NULL, NULL, GetModuleHandle(NULL), NULL);

    ShowWindow(hwnd, SW_SHOW);

    RAWINPUTDEVICE rid;
    rid.usUsagePage = 0x01;
    rid.usUsage = 0x02;
    rid.dwFlags = RIDEV_INPUTSINK;
    rid.hwndTarget = hwnd;
    RegisterRawInputDevices(&rid, 1, sizeof(rid));

    MSG msg = {};
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    return 0;
}