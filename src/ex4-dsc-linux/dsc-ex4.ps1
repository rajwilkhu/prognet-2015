configuration DscEx4
{
    param ([string[]]$computerName = 'localhost')

    Import-DSCResource -Module nx

    Node $computerName
    {
        nxScript KeepDirEmpty
        {
            GetScript = @"
#!/bin/bash
ls /tmp/mydir/ | wc -l
"@

            SetScript = @"
#!/bin/bash
rm -rf /tmp/mydir/*
"@

            TestScript = @'
#!/bin/bash
filecount=`ls /tmp/mydir | wc -l`
if [ $filecount -gt 0 ]
then
    exit 1
else
    exit 0
fi
'@
        } 
    }
}