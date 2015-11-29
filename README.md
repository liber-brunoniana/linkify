# Linkify
Linkify infers hyperlinks between articles. It constructs a bijection between filenames (which correspond to article names) and keywords, and searches for instances of those keywords in each file. When one is found, it is replaced with a hyperlink to that keyword's corresponding file.

Practically speaking, we split this into several steps. The first bijection simply strips the extension from the file name. Subsequent processing stages only run on articles about people (these are identified as any filename including a comma). There are several stages regarding people names, all involving some permuation of first, last and middle names.
