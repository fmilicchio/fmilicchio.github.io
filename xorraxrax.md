---
layout: landing
title: Reverse Engineering
description: Reverse Engineering of an EEG viewer and file format
image: assets/images/sre.jpg
nav-menu: true
---

<!-- Main -->
<div id="main">

<!-- Incipit -->
<section id="incipit">
	<div class="inner">
		<header class="major">
			<h2>Micromed EEG</h2>
		</header>
		<p>This is a journal of how I reversed engineered a file format, and a viewer for Microsoft Windows. The end result is <b>the NeuroLab project</b>, along with an ISO C library <b>libvwr</b>, both freely available and open source.</p>
		<p>Enjoy.</p>
		<section class="special">
			<ul class="actions fit">
				<li><a href="https://neurolabapp.bitbucket.io" class="button special">Visit NeuroLab</a></li>
			</ul>
		</section>
		<header>
			<h3>Abstract</h3>
		</header>
		<p>Neurology makes use of several tests, among them, the <a href="https://en.wikipedia.org/wiki/Electroencephalography">Electroencephalography</a> (EEG). It consists of several electrodes that are connected to the scalp of the patient, and the machine records a time-dependent signal corresponding to the difference of potential between two electrodes.</p>
		<p>Among the manufacturers of EEG machines, we have <a href="https://micromedgroup.com">Micromed</a>.</p>
		<p>This practical problem arose from the fact that <strong>there is no viewer outside Microsoft Windows</strong> for their file format, <strong>VWR</strong>. I needed a viewer because I've seen my wife not being able to open their files on her Apple laptop. Apart from personal reasons, it was a while since I worked in assembly and reverse engineered binaries. It sounded like fun, and it <b>was fun</b>.</p>
		<p>Hence, in order to visualize on macOS their EEGs, I needed to start from scratch. Reverse engineering a file format requires at least to have a program that can be run. Otherwise I had to do a lot of guesswork, and medical records do not mix with guesswork. Fortunately, I had their <strong>SystemViewer98</strong> application, whose name already promises to be fun to be reverse engineered.</p>
		<p>Here I will guide you through the process of reverse engineering a file format. The end result is a viewer, <strong>NeuroLab</strong>, published online for free.</p>
		<blockquote><strong>Legal disclaimer.</strong> This project is intended as  reverse engineering with the sole purpose of system interoperability, and it is protected under the law (L. 633/41 Art. 64, 22 April 1941, n. 633; L. 518/92 Art. 5, 29 December 1992).</blockquote>
	</div>
</section>

<!-- Story -->
<section class="spotlights">
	<section>
		<a href="{% link assets/images/sre/010.jpg %}" class="image">
			<img src="{% link assets/images/sre/010.jpg %}" alt="" data-position="top center" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>A First Look</h3>
				</header>
				<p>The first thing to do is to take a look at the binary file. I had used the fantastic <a href="https://www.sweetscape.com/010editor/">010 Editor</a> from SweetScape Software Inc. This hex editor has two great features: first, you can write a <em>template</em> to parse structures and binary data, and second, it's free for 30 days. This meant that I could not indulge in procrastinating. At first glance, we have as expected a header, with the clear name of the patient (here a fake one), other binary encoded stuff, and a list of sections (<tt>ORDER</tt>, <tt>LABCOD</tt>, ...).</p> 
				<p>The first bytes here are clearly a header, and it brings back memories of what I did back in the early 1990s. As you can see, the header starts with a human readable string, whose length is as one can see, 32 bytes. First we have 30 bytes, an ASCII string, followed by 0x00 0x1A.</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/dos.jpg %}" class="image">
			<img src="{% link assets/images/sre/dos.jpg %}" alt="" data-position="top center" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Old DOS Times</h3>
				</header>
				<p>I know that sequence. Back in the MS-DOS days, I used to block users to dump the contents of my files in the command prompt. You issued <b>type filename.ext</b> to get the contents of a file, and the hex 0x1A was handled by <b>COMMAND.COM</b> as EOF, the end-of-file character.</p>
				<p>As a proof, you can see in the image how it worked (still works?). I have created a file and with the <b>DEBUG.EXE</b> (the MS-DOS assembler included in MS-DOS) assembled <b>DB "hello", 1a, "world"</b>, and the contents after the 0x1a byte won't show. It was a neat trick with binary files, they won't pollute the prompt. <a href="https://www.pcjs.org/software/pcx86/sys/dos/microsoft/6.22/">Try that yourself online!</a></p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/systemviewer.jpg %}" class="image">
			<img src="{% link assets/images/sre/systemviewer.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>SystemViewer98</h3>
				</header>
				<p>Now we can skip the binary blob after the name, and take a look at the sections. Each section, for instance ORDER, is constituted by an 8 bytes ASCII string (the section name), followed by 8 bytes. As we are facing the SystemViewer98 executable, a 32-bit Win32 API binary, those 8 bytes must be read as 2 DWORDs, a 32 bits offset and 32 bits for the section size. It is highly unlikely that they implemented a 64 bit arithmetic by hand.</p>
				<p>The first step is to see what the application sees. As you can see, we have a very basic layout, with the EEG, the legend (the electrodes pair). The application has few controls, which I will replicate in my viewer, and a preset on which electrode pairs to display. The preset is just for the end user that can select different pairs, and all the original pairs recorded is called a <b>montage</b>, I've been told. Let's take a look at where I can find the pairs in the VWR.</p>
			</div>
		</div>
	</section>
</section>
<section>
	<div class="inner">
		<header class="major">
			<h3>Montage</h3>
		</header>
		<p>And here's the first weirdness: the number of electrode pairs is way too long. There are more pairs in the file that are not, apparently, present in the file.</p>
		<pre>
00000480  00 00 47 32 00 00 00 00  47 32 00 00 00 00 00 00  |..G2....G2......|
00000490  00 00 ff ff 00 00 00 80  00 00 80 f3 ff ff 80 0c  |................|
000004a0  00 00 00 00 96 00 00 00  00 00 00 00 01 00 80 00  |................|
000004b0  00 00 00 00 00 00 00 00  00 01 00 00 00 00 00 00  |................|
000004c0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000004e0  00 00 00 00 00 00 00 00  80 f3 ff ff 80 0c 00 00  |................|
000004f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000500  01 00 46 70 31 00 00 00  47 32 00 00 00 00 00 00  |..Fp1...G2......|
00000510  00 00 ff ff 00 00 00 80  00 00 80 f3 ff ff 80 0c  |................|
[...]
00000fe0  00 00 00 00 00 00 00 00  80 f3 ff ff 80 0c 00 00  |................|
00000ff0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00001000  00 00 41 31 00 00 00 00  47 32 00 00 00 00 00 00  |..A1....G2......|
00001010  00 00 ff ff 00 00 00 80  00 00 80 f3 ff ff 80 0c  |................|
		</pre>
	</div>
</section>
<section class="spotlights">
	<section>
		<a href="{% link assets/images/sre/allops.jpg %}" class="image">
			<img src="{% link assets/images/sre/allops.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Events</h3>
				</header>
				<p>Let's fire up <a href="https://docs.microsoft.com/en-us/sysinternals/downloads/procmon">Process Monitor</a> to see where to start. If I can see how the program behaves when opening a VWR file I will get a starting point. But be aware that Process Monitor will show <em>every event</em>, so it's advisable to setup a filter. In this case, the easiest filter is to include every event containing "VWR", case insensitively.</p>
				<p>So here we are, and we see that the application finds the given file, checks for read permissions, and weirdly enough, it will not read the file from the beginning.</p>
				<p>Thanks to this, I know where the entry point of the read function inside the executable is: it must be a <b>fseek</b> call with <b>175</b> offset, then it will read something important. Note that you cannot rely on the read length, as it will be buffered by the OS.</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/read.jpg %}" class="image">
			<img src="{% link assets/images/sre/read.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>The OCX</h3>
				</header>
				<p>Finding the offset it's easy, just look for <b>fseek</b> calls, and this can be easily done with  <a href="https://binary.ninja">Binary Ninja</a> by Vector 35, a very nice free (for some minutes at time) disassembler. But the search was unsuccessful.</p>
				<p>The package from Micromed contains some files, other than the executable. One in particular is an <a href="https://en.wikipedia.org/wiki/Object_Linking_and_Embedding">OCX file</a>, an OLE Control Extension for Microsoft Windows. At first I thought they've implemented the viewer (the graphic display of the signals) in the OCX, but apparently it does more.</p>
				<p>Looking at the stack trace of the read in the image, we can see that it's the OCX that manages everything. And lo and behold, we have our entry point.</p>
			</div>
		</div>
	</section>
</section>
<section>
	<div class="inner">
		<header class="major">
			<h3>File Seek</h3>
		</header>
		<p>After rewording some variables, you end up with the real code. As you can see we have 175, or 0xaf, being pushed to the stack, followed by what is clearly the second parameter of the <b>fseek</b> routine: the file handle. So now we have the file handle: offset <b>0xfa4b</b>.</p>
		<pre>
10007258 68 af 00        PUSH       0xaf
         00 00
1000725d 8b 85 b4        MOV        input_file,dword ptr [EBP + local_1850]
         e7 ff ff
10007263 8b 88 4b        MOV        ECX,dword ptr [input_file + 0xfa4b]
         fa 00 00
10007269 51              PUSH       ECX
1000726a ff 15 94        CALL       dword ptr [->MSVCRT.DLL::fseek] 
         24 01 10
		</pre>
	</div>
</section>
<section class="spotlights">
	<section>
		<a href="{% link assets/images/sre/read1byte.jpg %}" class="image">
			<img src="{% link assets/images/sre/read1byte.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>File Types</h3>
				</header>
				<p>Here's the surprise. At offset 175 we're just <b>before</b> the list of sections (ORDER, LABCOD, ...), off by one byte. And it reads exactly one byte. But here's the surprise: a VWR is not a single file format, but they have <em>versions</em>, for the lack of a better word. All the files I have have this byte set to 0x04. I'll proceed only in this direction, using <a href="https://hex-rays.com/ida-pro/">the IDA debugger</a>, a very powerful debugger that has great versatility by Hex Rays.</p>
				<p>As you can see from the assembly, the program now checks for this value, and it's a <b>switch</b>. How can you tell? Well, it's easy. Compilers usually output first the <b>default</b> branch, in assembly here, comparing bytes, is the <b>JA</b> opcode (jump if above). What about the values?</p>
				<p>The jump values are <b>stored in an array</b>, for instance here we have 5 values, <b>case 0 .. case default (== 5)</b>, so we will have an array in pseudo-C <b>uint32_t switchD_100072b3[5] = { 0x..., 0x..., 0x..., 0x..., 0x...};</b>, so all the computer has to do is <b>JMP dword ptr [value + ->switchD_100072b3]</b>.</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/readheader.jpg %}" class="image">
			<img src="{% link assets/images/sre/readheader.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Header Buffer</h3>
				</header>
				<p>The routine that reads the header gives us precious memory addresses, and more. Before you ask, what is that "<b>input_file</b>"? It's the first parameter of this Win32 function, it contains the global state of the OCX, which handles just one file at time. Easy to verify by opening a new file.</p>
				<p>The address <b>0x11f02</b> is obviously the buffer, so the function will read 640 bytes in that address. Funny number, it reminds me the <a href="https://en.wikipedia.org/wiki/Conventional_memory#640_KB_barrier">famous 640 KB of RAM</a> limiting MS-DOS without <b>HIMEM.SYS</b> or <b>EMM386.SYS</b> (later an EXE).</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/datechecks.jpg %}" class="image">
			<img src="{% link assets/images/sre/datechecks.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Checks</h3>
				</header>
				<p>Now things get interesting. We have several checks that are relative to the buffer, since the address checked is always <b>0x11f02 + offset</b>. Let's see what they are checking.</p>
				<p>At offset <b>0x11f6c</b> we have a comparison with 0xc, in decimal is 12. It's a month! So <b>buffer[106]</b> is a month (0x11f6c - 0x11f02 = 106), and so is <b>buffer[129]</b>, and then it follows quite easily that the adjacent bytes are dates. Two dates are present in the viewer, the patient's birth date and the exam's date: this is a confirmation. By checking the dates it's easy to see which is which, moreover, the exam date is followed by the time.</p>
				<p>The VWR format uses a single byte for everything, and the year is stored as <b>year - 1900</b>. This should not surprise you at all, it was common practice back in the DOS days. <a href="https://en.wikipedia.org/wiki/Year_2000_problem">The whole Y2K problem</a>, however, was really overblown and wasn't <em>that</em> problematic at all.</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/sections.jpg %}" class="image">
			<img src="{% link assets/images/sre/sections.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Sections</h3>
				</header>
				<p>Moving on with the code, we see now that we're reading now the sections, ORDER, LABCOD, and so on.</p>
				<p>The order of <b>fseek/fread</b> along with the offsets show us that the binary VWR stores the section information as:</p>
				<pre>
uint8_t name[8];
uint32_t offset;
uint32_t size;
				</pre>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/dataoffset.jpg %}" class="image">
			<img src="{% link assets/images/sre/dataoffset.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Data Offset</h3>
				</header>
				<p>After reading the file size by <b>fseek/ftell</b>, the routine will check two things. Here we focus on one, the other, a funnier one, is directly below.</p>
				<p>We can see the <b>IDIV</b>, the integer division opcode, used with the <b>file_size</b>. This indicates that we're looking for something <em>inside</em> the file. As I will confirm by looking at the painting routines, we're here checking the <b>signal data offset</b>.</p>
				<p>We have now that the operation seen here computes <b>file_size - buffer[138] = data size in bytes</b>, so at that offset in the file we have the signals.</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/checksum.jpg %}" class="image">
			<img src="{% link assets/images/sre/checksum.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Rudimentary Checksum</h3>
				</header>
				<p>The second check done in this routine is something very cute. As you can see in the picture after zeroing the <b>ret</b> variable (via <b>XOR</b>), the function will load bytes from the buffer.</p>
				<p>When checking where in the file it reads, we know that VWR contains a rudimentary checksum for the file: the <b>buffer[160]</b> contains the checksum, computed as <b>patient_surname[0] + patient_surname[1] + patient_surname[2] + patient_name[0] + patient_name[1] + patient_name[3] + patient_birth_day + patient_birth_month + patient_birth_year</b>.</p>
				<p>It would have been preferable to use, at that time, <a href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">the CRC32 checksum</a>, employed by all compressors like PKZIP (first release in 1989), the father of the ZIP file format (by Phil Zatz, hence the "PK").</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/unit.jpg %}" class="image">
			<img src="{% link assets/images/sre/unit.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Unit Conversion</h3>
				</header>
				<p>Still I needed a unit conversion from whatever the data is, to some meaningful floating point. Fortunately, the viewer has a clear routine that paints with MFC (<a href="https://en.wikipedia.org/wiki/Microsoft_Foundation_Class_Library">Microsoft Foundation Classes</a>). I've worked with this library before in C++, it was good, but the <a href="https://www.qt.io">Qt Library</a> that I use since 1999 cannot be beaten. Especially with the documentation. In the paint routine that handles all the <b>CPen</b> and <b>CDC</b> (Device Contex class, all MFC classes start with "C"), I find a call to a peculiar function. This function returns a floating point, you can see it uses the old FPU stack-based opcodes like <b>FILD</b> (float integer load) or <b>FIDIV</b> (float integer divide). FPU is a nightmare compared to MMX/SSE/AVX.</p>
				<p>The switch case in this function compares 0x0, 0x1, 0x2, and 0xffff, and stores a <em>weird</em> integer such as <b>MOV dword ptr [EBP + local_8], 0x3f800000</b> for the non-initiated, that constant is in reality the <b>floating point 1.0</b>, and we have also <b>0x447a0000 = 1000</b>, <b>0x49742400 = 1000000</b>, <b>0x3a83126f = 0.001</b>. Not only that, but also it converts between the data and the electrode pairs buffer. We <b>definitely</b> have our unit conversion.</p>
			</div>
		</div>
	</section>
</section>
<section>
	<div class="inner">
		<header class="major">
			<h3>Data Buffers</h3>
		</header>
		<p>With some painstaking cross-check in the code, we arrive at the following addresses (just an excerpt, it's long):</p>
		<pre>
0x11f02   = header buffer
0x11f6c   = month, buffer[106]
0x11f83   = month, buffer[129]
0x11f94   = order, buffer[146]
0x1025f   = file size
0xfa4b    = FILE* 
0x11fba   = ORDER offset
0x11fbe   = ORDER size
0x12182   = ORDER buffer
0x11fca   = LABCOD offset
0x11fce   = LABCOD size
0x12dcc   = LABCOD buffer
0xf2da    = NOTES offset
0xf2de    = NOTES size    
0xf2d2    = NOTES num items = NOTES size DIV 44
[...]
0x10263   = total number of samples
0x1202a   = MONTAGES offset
0x26dcc   = MONTAGES buffer
		</pre>
	</div>
</section>
<section class="spotlights">
	<section>
		<a href="{% link assets/images/sre/intsize.jpg %}" class="image">
			<img src="{% link assets/images/sre/intsize.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Integer Types</h3>
				</header>
				<p>The routine that reads the actual data is easy to find, and reveals something interesting. The VWR file format has no fixed type for the data.</p>
				<p>As you can see, the code compares a local stack variable, corresponding to sddress <b>0x11f96</b> to 1, 2, 4. The offset is <b>buffer[148]</b>, and the three numbers correspond to the <b>integer size</b> used by the VWR encoding, obviously corresponding to <b>uint8_t</b>, <b>uint16_t</b>, and <b>uint32_t</b>. We have already the routine that gives us floats, here we have the input.</p>
			</div>
		</div>
	</section>
	<section>
		<a href="{% link assets/images/sre/waveform.jpg %}" class="image">
			<img src="{% link assets/images/sre/waveform.jpg %}" alt="" data-position="top left" />
		</a>
		<div class="content">
			<div class="inner">
				<header class="major">
					<h3>Electrodes</h3>
				</header>
				<p>After some time dumping on screen, I now know how things work in a VWR, as you can see from the image of an EEG electrode signal.</p>
				<p>The LABCOD contains <b>all possible pairs</b> of electrodes, with their boundaries (logical and physical, as I have discovered by reading a book on EEG analysis). The ORDER section contains the <b>actual montage</b>, the electrodes pairs that were recorded with their numbers referring to LABCOD. NOTES contain <b>brief texts</b> that doctors may record regarding any event that occurred during the EEG exam (for instance "The patient sneezed", or "Moves the head"). In my files many other sections (e.g., FLAGS, TRONCA, IMPED_B, EVENT_A) were garbage, while MONTAGE contains <b>presets</b> that doctors want to see, subsets of electrode pairs: this is not interesting to me, as I will develop my own viewer, as you can see below.</p>
			</div>
		</div>
	</section>
</section>

<!-- Conclusions -->
<section id="three">
	<div class="inner">
		<header class="major">
			<h2>Conclusion</h2>
		</header>
		<p>Now the VWR data format is known, and I developed a library in ISO C, <b>libvwr</b>, along with the <b>vwrdump</b> tool that takes a VWR file and dumps the contents I have described above to a CSV file.</p> <p>I've chosen ISO C to maximize the interoperability with other languages, for instance Dart/Flutter. This proved to be a failure for performance reasons. I need to display approximately 1.5M samples per electrode pairs, with an average of 20 pairs. Flutter was painfully slow with just one signal constituted by 100K samples. That is why I am developing the viewer <b>NeuroLab</b> in C++ with the Qt Library, it's really fast, and portable on every platform.</p>
		<p>How long did it take? The <b>010 Editor</b> has a 30 days free trial, and I reverse engineered the viewer in 4 weeks. I worked for two hours on Saturday and Sunday, except the last week when I worked only on Saturday. That makes 14 hours more or less.</p>
		<p>It was fun, really.</p>
		<section class="special">
			<ul class="actions">
				<li><a href="https://neurolabapp.bitbucket.io" class="button special">Visit NeuroLab</a></li>
			</ul>
		</section>
	</div>
</section>

</div>
