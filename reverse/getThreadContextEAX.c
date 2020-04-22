#include <stdio.h>
#include <windows.h>
#include <winnt.h>


int main()
{
	HANDLE tHand;
	CONTEXT ctx;

	DWORD ctxAddr = (DWORD)(&ctx);
	DWORD eaxAddr = (DWORD)(&ctx.Eax);
	printf("Context: %#X\n", ctxAddr);
	printf("Eax: %#X\n", eaxAddr);
	printf("Offset: %#X\n", eaxAddr - ctxAddr);
	return 0;
}

