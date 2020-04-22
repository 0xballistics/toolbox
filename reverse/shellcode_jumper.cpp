#include <iostream>
#include <fstream>
#include <windows.h>
#include <cstdlib>

using namespace std;
int main(int argc, char* argv[]) {

	if (argc < 2 || argc > 3) {
		cout << "usage: " << argv[0] << " <shellcode bin file> [optional offset]" << endl;
		return 0;
	}
	uintptr_t offset = 0;
	if (argc == 3) {
		//offset = (uintptr_t)atoi(argv[2]);
		offset = (uintptr_t)std::strtoul(argv[2], 0, 16);
	}
	ifstream bin;
	bin.open(argv[1], ios::in | ios::binary);
	bin.seekg(0, bin.end);
	int shellcode_len = bin.tellg();
	bin.seekg(0, bin.beg);
	LPVOID shellcode = VirtualAlloc(NULL, shellcode_len, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	bin.read((char*)shellcode, shellcode_len);
	int(*f)() = (int(*)())((uintptr_t)shellcode + offset);
	f();
	VirtualFree(shellcode, 0, MEM_RELEASE);
	bin.close();
	return 0;
}

