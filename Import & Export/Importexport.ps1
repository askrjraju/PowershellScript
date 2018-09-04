#disabled 8.3
 fsutil.exe behavior set disable8dot3 1

 # For resume session
WAImportExport.exe PrepImport /j:seconddrive.jrn /id:camera#1 /ResumeSession

# first copy of first frive : calcenter backup
WAImportExport.exe PrepImport /j:FirstDrive.jrn /id:callcenter#1 /logdir:c:\Logs /sk:MVD6k0aj8GRVJOyrHNjpMoVLYcvoJ6MihtZxC0GyzBNRDsCtwPD0kWWrOiHughFsWuNoc9JLgLWFBw6B41VhCg== /t:Z /format /encrypt /srcdir:D:\ /dstdir:callcenterbkp/

# second copy of first Drive :calcenter backup
WAImportExport.exe PrepImport /j:FirstDrive.jrn /id:Callcenter#2 /srcdir:f:\ /dstdir:callcenterbkp/

# Third copy of firstdrive
WAImportExport.exe PrepImport /j:FirstDrive.jrn /id:Callcenter#3 /srcdir:G:\ /dstdir:callcenterbkp/

# Forth copy of first drive : calcenter backup
WAImportExport.exe PrepImport /j:FirstDrive.jrn /id:Callcenter#4 /srcdir:H:\ /dstdir:callcenterbkp/ /bk: 


# First copy of second drive : camera bkp

WAImportExport.exe PrepImport /j:seconddrive.jrn /id:camera#1 /logdir:c:\Logs /sk:MVD6k0aj8GRVJOyrHNjpMoVLYcvoJ6MihtZxC0GyzBNRDsCtwPD0kWWrOiHughFsWuNoc9JLgLWFBw6B41VhCg== /t:x /format /encrypt /srcdir:D:\NVRBackup\ /dstdir:camerabkp/


# Third drive : calcenter backup
WAImportExport.exe PrepImport /j:Thirddrive.jrn /id:callcenter#6 /logdir:c:\Logs /sk:MVD6k0aj8GRVJOyrHNjpMoVLYcvoJ6MihtZxC0GyzBNRDsCtwPD0kWWrOiHughFsWuNoc9JLgLWFBw6B41VhCg== /t:Z /format /encrypt /srcdir:D:\ /dstdir:callcenterbkp/

# Third drive : calcenter backup
second session

WAImportExport.exe PrepImport /j:Thirddrive.jrn /id:Callcenter#7 /srcdir:D:\ /dstdir:callcenterbkp/ 

# Fourth Drive : camera bkp
WAImportExport.exe PrepImport /j:forthdrive.jrn /id:camera#2 /logdir:c:\Logs /sk:MVD6k0aj8GRVJOyrHNjpMoVLYcvoJ6MihtZxC0GyzBNRDsCtwPD0kWWrOiHughFsWuNoc9JLgLWFBw6B41VhCg== /t:W /format /encrypt /srcdir:F:\ /dstdir:camerabkp/

# forth drive camera bkp
WAImportExport.exe PrepImport /j:forthdrive.jrn /id:camera#3 /srcdir:c:\record /dstdir:camerabkp/

#Forth drive : camera bkp
WAImportExport.exe PrepImport /j:forthdrive.jrn /id:camera#4 /srcdir:D:\ /dstdir:camerabkp/

# Fifth drive : pictureproductionbkp

WAImportExport.exe PrepImport /j:FifthDrive.jrn /id:production#1 /logdir:c:\Logs /sk:MVD6k0aj8GRVJOyrHNjpMoVLYcvoJ6MihtZxC0GyzBNRDsCtwPD0kWWrOiHughFsWuNoc9JLgLWFBw6B41VhCg== /t:v /format /encrypt /srcdir:D:\ /dstdir:pictureproductionbkp/

Fifth Drive : file server
WAImportExport.exe PrepImport /j:FifthDrive.jrn /id:fileserver#1 /srcdir:C:\Tally\ /dstdir:fileserverbkp/