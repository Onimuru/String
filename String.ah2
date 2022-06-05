#Requires AutoHotkey v2.0-beta

/*
* MIT License
*
* Copyright (c) 2022 Onimuru
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

;============ Auto-Execute ====================================================;

PatchStringBase()
PatchStringPrototype()

;============== Function ======================================================;

PatchStringBase() {

	;--------------- Custom -------------------------------------------------------;

	String.Base.DefineProp("IsPalindrome", {Call: (class, string) => (RegExReplace(string, "S)[\s.,?!;']") = DllCall("msvcrt\_wcsrev", "Str", RegExReplace(string, "S)[\s.,?!;']"), "UInt", 0, "Str"))})

	String.Base.DefineProp("IsUrl", {Call: (class, string) => (IsUrl(string))})

	IsUrl(string) {
		static needle := "S)((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)"

		return (string ~= needle)
	}

	;* String.Inverse(string)
	String.Base.DefineProp("Inverse", {Call: (class, string) => (RegExReplace(string, "([A-Z])|([a-z])", "$L1$U2"))})

	;* String.Repeat(string, times)
	String.Base.DefineProp("Repeat", {Call: (class, string, times) => (StrReplace(Format("{:0" . times . "}", 0), "0", string))})

	;* String.Reverse(string)
	String.Base.DefineProp("Reverse", {Call: (class, string) => (Reverse(string))})

	Reverse(string) {
		d := Chr(959), s := ""

		for i, v in StrSplit(StrReplace(string, d, "`r`n")) {
			s := v . s
		}

		return (StrReplace(s, "`r`n", d))
	}

	;* String.Split(string[, delimiter, omitChars, maxParts])
	;* Description:
		;* Separates a string into an array of substrings using the specified delimiters.
	String.Base.DefineProp("Split", {Call: (class, params*) => (StrSplit(params*))})

	;* String.Strip(string, characters)
	;* Description:
		;* Remove all occurrences of `characters` from a string.
	String.Base.DefineProp("Strip", {Call: (class, string, characters) => (RegExReplace(string, "[" . characters . "]"))})

	;* String.Split(string[, characters])
	;* Description:
		;* Removes leading and trailing `characters` from a string.
	String.Base.DefineProp("Trim", {Call: (class, params*) => (Trim(params*))})

	String.Base.DefineProp("Buffer", {Call: (class, string, commentCharacter, bufferCharacter, bufferLength, offset := "", specialBuffer := 0) => (Buffer(string, commentCharacter, bufferCharacter, bufferLength, offset, specialBuffer))})

	Buffer(string, commentCharacter, bufferCharacter, bufferLength, offset, specialBuffer) {
		if (offset == "") {
			offset := bufferLength//2
		}

		stringLength := StrLen(string)
			, subtract := Ceil(stringLength/2) + StrLen(commentCharacter) + 1, isOdd := stringLength & 1

		leftOffset := 0, rightOffset := 0

		if (!specialBuffer && isOdd) {
			if (offset <= bufferLength//2) {
				rightOffset := 1
			}
			else {
				leftOffset := 1
			}
		}

		return (commentCharacter
			. StrReplace(Format("{:0" . offset - subtract + leftOffset . "}", 0), "0", bufferCharacter)
			. ((specialBuffer && isOdd) ? (Format("  {}  ", string)) : (Format(" {} ", string)))
			. StrReplace(Format("{:0" . bufferLength - offset - subtract + rightOffset . "}", 0), "0", bufferCharacter)
			. commentCharacter)
	}

	;* String.Copy([getLine, getLine])
	;* Description:
		;* Copies and returns the selected text or optionally the whole line if no text is selected while preserving the clipboard content.
	String.Base.DefineProp("Copy", {Call: (class, getLine := False, trim := False) => (Copy(getLine, trim))})

	Copy(getLine, strip) {
		c := ClipboardAll()
		A_Clipboard := ""

		Send("^c")

		if (!ClipWait(0.2) && getLine) {
			Send("{Home}+{End}^c")
			ClipWait(0.2)

			if (A_Clipboard) {
				Send("{Right}")
			}
		}

		s := (strip) ? (Trim(A_Clipboard)) : (A_Clipboard)
		A_Clipboard := c

		return (s)
	}

	;* String.Clipboard.Paste(string[, select])
	;* Description:
		;* Paste the provided text while preserving the clipboard content and optionally select the text that was pasted.
	String.Base.DefineProp("Paste", {Call: (class, string, select := False) => (Paste(string, select))})

	Paste(string, select) {
		c := ClipboardAll()
		A_Clipboard := ""

		Sleep(25)
		A_Clipboard := string

		Send("^v")

		Sleep(25)
		A_Clipboard := c

		if (select) {
			select := 0

			if (InStr(string, "`n")) {
				for i, v in StrSplit(StrReplace(string, "`n", "`r")) {
					select += StrLen(A_LoopField) + (A_Index != 1)
				}
			}

			Send(Format("+{Left {:1}}", Max(select, StrLen(string))))
		}
	}
}

PatchStringPrototype() {
	DefineProp := {}.DefineProp

	;--------------- Custom -------------------------------------------------------;

	DefineProp("".Base, "Length", {Get: StrLen})

	;----------------  MDN  --------------------------------------------------------;

	DefineProp("".Base, "ToLowerCase", {Call: ToLowerCase})

	;* "String".ToLowerCase()
	ToLowerCase(this) {
		return (Format("{:L}", this))
	}

	DefineProp("".Base, "ToUpperCase", {Call: ToUpperCase})

	;* "String".ToUpperCase()
	ToUpperCase(this) {
		return (Format("{:U}", this))
	}

	DefineProp("".Base, "Includes", {Call: Includes})

	;* "String".Includes(needle[, start])
	Includes(this, needle, start := 0) {
		return (InStr(this, needle, 1, Max(0, Min(StrLen(this), Round(start))) + 1) != 0)
	}

	DefineProp("".Base, "IndexOf", {Call: IndexOf})

	;* "String".IndexOf(needle[, start])
	IndexOf(this, needle, start := 0) {
		return (InStr(this, needle, 1, Max(0, Min(StrLen(this), Round(start))) + 1) - 1)
	}

	DefineProp("".Base, "Reverse", {Call: Reverse})

	;* "String".Reverse()
	Reverse(this) {
		static d := Chr(959)

		for i, v in StrSplit(StrReplace(this, d, "`r`n")) {
			r := v . r
		}

		return (StrReplace(r, "`r`n", d))  ;! DllCall("msvcrt\_wcsrev", "Ptr", StrPtr(this), "UInt", 0, "Str")
	}

	DefineProp("".Base, "Slice", {Call: Slice})

	;* "String".Slice(start[, end])
	Slice(this, start, end := "") {
		m := StrLen(this)

		return (SubStr(this, start + 1, Max(((IsInteger(end)) ? (((end >= 0) ? (Min(m, end)) : (Max(m + end, 0))) - ((start >= 0) ? (Min(m, start)) : (Max(m + start, 0)))) : (m)), 0)))
	}

	DefineProp("".Base, "Trim", {Call: Trim})

	;* "String".Trim([characters])
	Trim(this, characters := " ") {
		return (Trim(this, characters))
	}
}
