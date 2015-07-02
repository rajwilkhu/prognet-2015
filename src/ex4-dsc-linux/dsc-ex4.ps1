configuration DscEx4
{
    param ([string[]]$computerName = 'localhost')

    Import-DSCResource -Module nx

    Node $computerName
    {
        nxService ssh
        { 
             Name = "sshd"
             Controller = "init" 
             Enabled = "True" 
             State = "Running" 
        } 

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

        nxScript AddFirewallRule 
        {
            SetScript = @'
#!/bin/bash
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport http -j ACCEPT
/etc/init.d/iptables save
'@
            TestScript = @'
#!/bin/bash
iptables -L | grep ^ACCEPT | grep "dpt:http "
exit $?
'@
            GetScript = @'
#!/bin/bash
iptables -L | grep ^ACCEPT | grep "dpt:http "
'@
        } 
    }
}