What Is It?
===========

Hammerhead (<http://www.threechords.com/hammerhead/>) is a old drum machine for Windows. One of its features allows you to import new drum sounds using a file format called HUB. Clawhammer.rb allows you to extract the samples out of a HUB file into individual \*.wav files. This allows you to use the samples in any music program that supports \*.wav (just about everything).

The HUB file format was reverse-engineered using [FileInspector.rb](http://github.com/jstrait/fileinspector/tree/master). For more on the HUB file format, see section below.


Usage
=====

    ruby clawhammer.rb [name of HUB file]

Example:
    ruby clawhammer.rb groove.hub
Output files:
    Groove-1.wav
    Groove-2.wav
    Groove-3.wav
    Groove-4.wav
    Groove-5.wav
    Groove-6.wav

Clawhammer uses the [WaveFile gem](http://www.github.com/jstrait/wavefile) to create the output wave files. Therefore, you will need to have the gem installed on your machine. To do so, run the following command:

	sudo gem install jstrait-wavefile -s http://gems.github.com

About the HUB Format
====================

The HUB format is very simple. A HUB file contains 6 records, which represent each of the samples stored in the file. Each record contains a header, followed by actual sample data.

<pre>[    Header 1   ]
[ Sample 1 Data ]
[    Header 2   ]
[ Sample 2 Data ]
[    Header 3   ]
[ Sample 3 Data ]
[    Header 4   ]
[ Sample 4 Data ]
[    Header 5   ]
[ Sample 5 Data ]
[    Header 6   ]
[ Sample 6 Data ]</pre>

Each header is 36 bytes, and has the following format:

<table>
<tr>
    <th>Bytes</th>
    <th>Description</th>
    <th>Data Format</th>
</tr>
<tr>
    <td>0:</td>
    <td>Length of the HUB title, in bytes.</td>
    <td>Integer. Signed or unsigned doesn't matter, since the maximum valid value is 30.</td>
</tr>
<tr>
    <td>1-30:</td>
    <td>HUB title. If HUB title is less than 30 characters, the extra bytes will be garbage. The title will be identical for each header.</td>
    <td>1-byte ASCII characters</td>
</tr>
<tr>
    <td>31-34:</td>
    <td>Length of the sound's sample data, in bytes.</td>
    <td>Unsigned, little-endian</td>
</tr>
<tr>
    <td>35:</td>
    <td>Flag for whether sample should be stretched to fill a full measure when played in Hammerhead. (For example, a drum loop). Ignored by Clawhammer.</td>
    <td>0x01 for true, 0x00 for false</td>
</tr>
</table>

Byte 0: Length of HUB title.
  1-30: HUB title. If HUB title is less than 30 characters,
        remaining bytes are garbage. It will be identical for each record.
 31-34: Length of sample data, in unsigned little-endian format.
    35: Flag for whether sample should be looped when played in Hammerhead. Ignored by Clawhammer.

The sample data payload follows the header. The length of the sample data is indicated in bytes 31-34 of the header.

The sample data in each record only includes raw sample data, and not the 44 byte header specified by the \*.wav format. Hammerhead assumes that samples are 16-bit, 1 channel (mono), and with a sample rate of 44100. Therefore, the header for each output \*.wav file will be identical, expect for the payload size. (For more on the \*.wav format, visit http://ccrma.stanford.edu/courses/422/projects/WaveFormat/ ).