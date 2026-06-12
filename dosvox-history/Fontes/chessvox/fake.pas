unit fake;

interface

function get_ms: integer;
function ftime_ok: boolean;


implementation

function get_ms: integer; begin end;
function ftime_ok: boolean; begin end;


(*
/* get_ms() returns the milliseconds elapsed since midnight,
   January 1, 1970. */
#include <sys/timeb.h>

BOOL ftime_ok = FALSE;  /* does ftime return milliseconds? */
int get_ms()
begin
	struct timeb timebuffer;
	ftime(&timebuffer);
	if (timebuffer.millitm != 0)
		ftime_ok = TRUE;
	return (timebuffer.time * 1000) + timebuffer.millitm;
}

*)
end.
