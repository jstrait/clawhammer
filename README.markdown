What Is It?
===========

Hammerhead (<http://www.threechords.com/hammerhead/>) is a old drum machine for Windows. One of its features allows you to import new drum sounds using a file format called HUB. Clawhammer.rb allows you to extract the samples out of a HUB file into individual *.wav files. This allows you to use the samples in any music program that supports *.wav (just about everything).

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

Byte 0: Length of HUB title.
  1-30: HUB title. If HUB title is less than 30 characters,
        remaining bytes are garbage. It will be identical for each record.
 31-34: Length of sample data, in unsigned little-endian format.
    35: Flag for whether sample should be looped when played in Hammerhead. Ignored by Clawhammer.

The sample data payload follows the header. The length of the sample data is indicated in bytes 31-34 of the header.

The sample data in each record only includes raw sample data, and not the 44 byte header specified by the *.wav format. Hammerhead assumes that samples are 16-bit, 1 channel (mono), and with a sample rate of 44100. Therefore, the header for each output *.wav file will be identical, expect for the payload size. (For more on the *.wav format, visit http://ccrma.stanford.edu/courses/422/projects/WaveFormat/ ).