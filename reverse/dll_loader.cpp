#include <iostream>
#include <windows.h>

using namespace std;

typedef int(__stdcall *f_funci)();

int main(int argc, char* argv[]) {
	if (argc < 2 || argc > 3) {
		cout << "usage: " << argv[0] << " <dll path> [optional function]" << endl;
		return 0;
	}
	char* library = argv[1];
	char* func = NULL;
	if (argc == 3) {
		func = argv[2];
	}

	HINSTANCE hGetProcIDDLL = LoadLibraryA(library);
	if (!hGetProcIDDLL) {
		cout << "could not load the dynamic library. ErrCode:" << GetLastError() << endl;
		return EXIT_FAILURE;
	}
	if (func) {
		f_funci funci = (f_funci)GetProcAddress(hGetProcIDDLL, func);
		if (!funci) {
			cout << "could not locate the function. ErrCode:" << GetLastError() << endl;
			return EXIT_FAILURE;
		}
		funci();
	}
	
	FreeLibrary(hGetProcIDDLL);
}
