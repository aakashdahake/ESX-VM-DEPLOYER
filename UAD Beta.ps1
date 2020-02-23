#Author:Aakash Dahake
#aakashdahake@gmail.com

Add-Type -AssemblyName System.Windows.Forms

#Load Assemblies
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null


#Detects a program is installed or not
function IsInstalled( $program ) {
    
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    return $x86 -or $x64;
}


#==============GUI Objects====================================
function LaunchApp
{

    $hosts = '192.168.197.211','192.168.197.254','192.168.139.22'

    $Form1 = New-Object System.Windows.Forms.Form
    $Form1.ClientSize = New-Object System.Drawing.Size(407, 390)
    $form1.topmost = $true
    #$form1.Icon = "C:\icon.ico"
    $form1.Text = "EVMD - Deploy on ESX"
    $form1.Width = 340
    $Form1.Height = 420
    $Form1.FormBorderStyle = 'Fixed3D'
    $Form1.MaximizeBox = $false
    $Form1.StartPosition = "centerscreen"
    $Form1.BackColor = 'Black'

    $by = New-Object System.Windows.Forms.Label
    $by.Location = New-Object System.Drawing.Point(220, 364)
    $by.Size = New-Object System.Drawing.Size(200, 23)
    $by.Text = "by Aakash Dahake"
    $by.ForeColor = "White"
    $by.BackColor = 'Transparent'
    $Form1.Controls.Add($by)

    $mod = New-Object System.Windows.Forms.Label
    $mod.Location = New-Object System.Drawing.Point(57, 15)
    $mod.Size = New-Object System.Drawing.Size(400, 23)
    $mod.Text = "ESX VM DEPLOYER (BETA)"
    $mod.ForeColor = "White"
    $mod.BackColor = 'Transparent'
    $Form1.Controls.Add($mod)

    $cb1 = New-Object System.Windows.Forms.ComboBox
    $cb1.Location = New-Object System.Drawing.Point(85, 168)
    $cb1.Size = New-Object System.Drawing.Size(200, 23)
    $hosts | % {$cb1.Items.Add($_)}
    $cb1.Text = '192.168.197.211'
    $Form1.Controls.Add($cb1)

    #Datastore list
    $cb2 = New-Object System.Windows.Forms.ComboBox
    $cb2.Location = New-Object System.Drawing.Point(85, 47)
    $cb2.Size = New-Object System.Drawing.Size(200, 23)

    #Storage label
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(15, 77)
    $label2.Size = New-Object System.Drawing.Size(70, 23)
    $label2.Text = "Space"
    $label2.ForeColor = "White"
    $label2.BackColor = 'Transparent'

    #Storage status
    $tbst = New-Object System.Windows.Forms.TextBox
    $tbst.Location = New-Object System.Drawing.Point(85, 74)
    $tbst.Size = New-Object System.Drawing.Size(200, 23)
    $tbst.ReadOnly = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(15, 172)
    $label.Size = New-Object System.Drawing.Size(70, 23)
    $label.Text = "Select ESX"
    $label.BackColor = "Transparent"
    $label.ForeColor = 'White'
    $Form1.Controls.Add($label)

    $labe2 = New-Object System.Windows.Forms.Label
    $labe2.Location = New-Object System.Drawing.Point(15, 50)
    $labe2.Size = New-Object System.Drawing.Size(70, 23)
    $labe2.Text = "Datastores"
    $labe2.ForeColor = "White"
    $labe2.BackColor = 'Transparent'

    $luser = New-Object System.Windows.Forms.Label
    $luser.Location = New-Object System.Drawing.Point(15, 203)
    $luser.Size = New-Object System.Drawing.Size(70, 23)
    $luser.Text = "Username"
    $luser.ForeColor = "White"
    $luser.BackColor = 'Transparent'
    $Form1.Controls.Add($luser)

    $tbuser = New-Object System.Windows.Forms.TextBox
    $tbuser.Location = New-Object System.Drawing.Point(85, 200)
    $tbuser.Size = New-Object System.Drawing.Size(200, 23)
    $tbuser.Text = "root"
    $Form1.Controls.Add($tbuser)

    $lpass = New-Object System.Windows.Forms.Label
    $lpass.Location = New-Object System.Drawing.Point(15, 233)
    $lpass.Size = New-Object System.Drawing.Size(70, 23)
    $lpass.Text = "Password"
    $lpass.ForeColor = "White"
    $lpass.BackColor = 'Transparent'
    $Form1.Controls.Add($lpass)

    $tbpass = New-Object System.Windows.Forms.TextBox
    $tbpass.Location = New-Object System.Drawing.Point(85, 230)
    $tbpass.Size = New-Object System.Drawing.Size(200, 23)
    $tbpass.Text = ""
    $Form1.Controls.Add($tbpass)

    $lwarn = New-Object System.Windows.Forms.Label
    $lwarn.Location = New-Object System.Drawing.Point(85, 260)
    $lwarn.Size = New-Object System.Drawing.Size(200, 23)
    $lwarn.ForeColor = 'Red'
    $lwarn.BackColor = 'Transparent' 

    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(85, 285)
    $Button.Size = New-Object System.Drawing.Size(98, 23)
    $Button.Text = "Connect"
    $Button.BackColor = 'White'
    $Button.add_Click{
                        
                        if(test-connection ($cb1.Text) -Count 1 -ErrorAction SilentlyContinue)
                        {
                            #Uncomment to connect to actual ESX, currently commecnted in order to prceed to nect GUI screen
                            #$IsESXConnected = connect ($cb1.Text) ($tbuser.Text) ($tbpass.Text)
                            
                            #Remove below line to connect to actaul ESX 
                            $IsESXConnected ="True"

                            if($IsESXConnected -eq "True") 
                            { 
                                Config ($cb1.Text)
                            } 
                            else 
                            {$lwarn.Text = "Authentication failed"; $Form1.Controls.Add($lwarn)}
                        }
                        else {$lwarn.Text = "ESX not Reachable"; $Form1.Controls.Add($lwarn)}

                    }
    $Form1.Controls.Add($Button)
    


    $cb3 = New-Object System.Windows.Forms.ComboBox
    $cb3.Location = New-Object System.Drawing.Point(85, 128)
    $cb3.Size = New-Object System.Drawing.Size(200, 23)
    #$cb3.DropDownStyle = 'DropDownList'

    $lwin = New-Object System.Windows.Forms.Label
    $lwin.Location = New-Object System.Drawing.Point(15, 131)
    $lwin.Size = New-Object System.Drawing.Size(70, 23)
    $lwin.Text = "Windows"
    $lwin.ForeColor = "White"
    $lwin.BackColor = 'Transparent'

    $cb4 = New-Object System.Windows.Forms.ComboBox
    $cb4.Location = New-Object System.Drawing.Point(85, 155)
    $cb4.Size = New-Object System.Drawing.Size(200, 23)
    #$cb4.DropDownStyle = 'DropDownList'

    $ledi = New-Object System.Windows.Forms.Label
    $ledi.Location = New-Object System.Drawing.Point(15, 158)
    $ledi.Size = New-Object System.Drawing.Size(70, 23)
    $ledi.Text = "Edition"
    $ledi.ForeColor = "White"
    $ledi.BackColor = 'Transparent'

    # Combobox for option of Custom OVA/VM
    $cb5 = New-Object System.Windows.Forms.ComboBox
    $cb5.Location = New-Object System.Drawing.Point(85, 101)
    $cb5.Size = New-Object System.Drawing.Size(200, 23)

    #Label for deploy option CB
    $ldep = New-Object System.Windows.Forms.Label
    $ldep.Location = New-Object System.Drawing.Point(15, 104)
    $ldep.Size = New-Object System.Drawing.Size(70, 23)
    $ldep.Text = "Deploy"
    $ldep.ForeColor = "White"
    $ldep.BackColor = 'Transparent'

    #VM Name label
    $vmname = New-Object System.Windows.Forms.Label
    $vmname.Location = New-Object System.Drawing.Point(15,185)
    $vmname.Size = New-Object System.Drawing.Size(70, 23)
    $vmname.Text = "VM Name"
    $vmname.ForeColor = "White"
    $vmname.BackColor = 'Transparent'

    #VM Name box 
    $nb = New-Object System.Windows.Forms.TextBox
    $nb.Location = New-Object System.Drawing.Point(85, 182)
    $nb.Size = New-Object System.Drawing.Size(200, 23)

    #IP box 
    $ipbox = New-Object System.Windows.Forms.TextBox
    $ipbox.Location = New-Object System.Drawing.Point(85, 209)
    $ipbox.Size = New-Object System.Drawing.Size(200, 23)

    #IP Label 
    $iplb = New-Object System.Windows.Forms.Label
    $iplb.Location = New-Object System.Drawing.Point(15,212)
    $iplb.Size = New-Object System.Drawing.Size(70, 23)
    $iplb.Text = "IP"
    $iplb.ForeColor = "White"
    $iplb.BackColor = 'Transparent'

    #Gateway Label 
    $gtlb = New-Object System.Windows.Forms.Label
    $gtlb.Location = New-Object System.Drawing.Point(15,239)
    $gtlb.Size = New-Object System.Drawing.Size(70, 23)
    $gtlb.Text = "Gateway"
    $gtlb.ForeColor = "White"
    $gtlb.BackColor = 'Transparent'

    #Gateway box 
    $gtbox = New-Object System.Windows.Forms.TextBox
    $gtbox.Location = New-Object System.Drawing.Point(85, 236)
    $gtbox.Size = New-Object System.Drawing.Size(200, 23)

    #DNS Label 
    $dnslb = New-Object System.Windows.Forms.Label
    $dnslb.Location = New-Object System.Drawing.Point(15,266)
    $dnslb.Size = New-Object System.Drawing.Size(70, 23)
    $dnslb.Text = "DNS"
    $dnslb.ForeColor = "White"
    $dnslb.BackColor = 'Transparent'

    #DNS box 
    $dnsbox = New-Object System.Windows.Forms.Combobox
    $dnsbox.Location = New-Object System.Drawing.Point(85, 263)
    $dnsbox.Size = New-Object System.Drawing.Size(200, 23)
    $dnsbox.Datasource = '192.168.20.100','192.168.20.168','10.151.3.17','192.168.59.25'

    #Deployment time Label 
    $dptlb = New-Object System.Windows.Forms.Label
    $dptlb.Location = New-Object System.Drawing.Point(15,212)
    $dptlb.Size = New-Object System.Drawing.Size(150, 23)
    $dptlb.ForeColor = "White"
    $dptlb.BackColor = 'Transparent'

    #Deploy button
    $button2 = New-Object System.Windows.Forms.Button
    $button2.Location = New-Object System.Drawing.Point(185, 327)
    $button2.Size = New-Object System.Drawing.Size(98, 23)
    $button2.Text = "Deploy >"
    $button2.BackColor = 'White'
    $button2.add_Click{
                        $pass = CheckIPAvailability ($ipbox.Text)
                        if($pass -eq $false)
                        {
                            $Form1.Hide()
                            Deploy ($cb2.Text) ($cb3.Text) ($cb4.Text) ($cb5.Text) ($nb.Text) ($ipbox.Text) ($gtbox.Text)  ($dnsbox.Text) ($cb1.Text)  ;
                        }
                        else { $Form1.SendToBack(); (New-Object -ComObject Wscript.Shell).Popup("Entered IP is already in use, Please enter different one",0,"Warning",0) }
                    }
    #Back button from Deploy screen
    #Deploy button
    $button4 = New-Object System.Windows.Forms.Button
    $button4.Location = New-Object System.Drawing.Point(85, 327)
    $button4.Size = New-Object System.Drawing.Size(98, 23)
    $button4.Text = "< Back"
    $button4.BackColor = 'White'
    $button4.add_Click{ Disconnect-VIServer * -Confirm:$false;
                        MainScreen }

    #Checkbox for adding extra disk
    $cbox1 = New-Object System.Windows.Forms.CheckBox
    $cbox1.Location = New-Object System.Drawing.Point(85, 297)
    $cbox1.Size = New-Object System.Drawing.Size(15, 23)
    $cbox1.BackColor= "Transparent"

    #checkbox1 label
    $cboxl = New-Object System.Windows.Forms.Label
    $cboxl.Location = New-Object System.Drawing.Point(15,300)
    $cboxl.Size = New-Object System.Drawing.Size(70, 23)
    $cboxl.Text = "Add Disk"
    $cboxl.ForeColor = "White"
    $cboxl.BackColor = 'Transparent'
    $cboxl.Enabled = $true

    #Add Disk textbox
    $ctbox = New-Object System.Windows.Forms.TextBox
    $ctbox.Location = New-Object System.Drawing.Point(110, 297)
    $ctbox.Size = New-Object System.Drawing.Size(90, 23)
    $ctbox.Enabled = $false
    $ctbox.Text = 'Size in GB'

    #About  label and textbox
    $abtl = New-Object System.Windows.Forms.Label
    $abtl.Location = New-Object System.Drawing.Point(10, 364)
    $abtl.Size = New-Object System.Drawing.Size(70, 23)
    $abtl.ForeColor = "White"
    $abtl.BackColor = 'Transparent'
    $abtl.Text = "About "
    $abtl.add_Click({About })
    $abttb = New-Object System.Windows.Forms.TextBox
    $abttb.Location = New-Object System.Drawing.Point(8, 8)
    $abttb.Size = New-Object System.Drawing.Size(306, 351)
    $abttb.Multiline = $true
    $abttb.ScrollBars = "Vertical"
    $Form1.Controls.Add($abtl)

    #Deploying label
    $depol = New-Object System.Windows.Forms.Label
    $depol.Location = New-Object System.Drawing.Point(15,65)
    $depol.Size = New-Object System.Drawing.Size(150, 20)
    $depol.Text = "Deploying Template..."
    $depol.ForeColor = "White"
    $depol.BackColor = 'Transparent'
    
    #Starting VM label
    $startl = New-Object System.Windows.Forms.Label
    $startl.Location = New-Object System.Drawing.Point(15,105)
    $startl.Size = New-Object System.Drawing.Size(150, 20)
    $startl.Text = "Starting VM..."
    $startl.ForeColor = "White"
    $startl.BackColor = 'Transparent'
    
    #Dep Serverlabel
    $depsl = New-Object System.Windows.Forms.Label
    $depsl.Location = New-Object System.Drawing.Point(15,45)
    $depsl.Size = New-Object System.Drawing.Size(200, 20)
    $depsl.ForeColor = "White"
    $depsl.BackColor = 'Transparent'
    
    #Adding DiskServerlabel
    $addl = New-Object System.Windows.Forms.Label
    $addl.Location = New-Object System.Drawing.Point(15,85)
    $addl.Size = New-Object System.Drawing.Size(200, 20)
    $addl.ForeColor = "White"
    $addl.BackColor = 'Transparent'
    $addl.Text = 'No Disk to add..'
    
    #Adding DiskServerlabel
    $progl = New-Object System.Windows.Forms.Label
    $progl.Location = New-Object System.Drawing.Point(15,20)
    $progl.Size = New-Object System.Drawing.Size(200, 20)
    $progl.ForeColor = "White"
    $progl.BackColor = 'Transparent'
    $progl.Text = '------------PROGRESS------------'
    
    #VM status label
    $vmsl = New-Object System.Windows.Forms.Label
    $vmsl.Location = New-Object System.Drawing.Point(15,125)
    $vmsl.Size = New-Object System.Drawing.Size(300, 20)
    $vmsl.ForeColor = "White"
    $vmsl.BackColor = 'Transparent'
    
    #Done label
    $donel = New-Object System.Windows.Forms.Label
    $donel.Location = New-Object System.Drawing.Point(15,145)
    $donel.Size = New-Object System.Drawing.Size(300, 20)
    $donel.ForeColor = "White"
    $donel.BackColor = 'Transparent'
    $donel.Text = 'Done'
    
    #Open in Browser button
    $button3 = New-Object System.Windows.Forms.Button
    $button3.Location = New-Object System.Drawing.Point(185, 250)
    $button3.Size = New-Object System.Drawing.Size(98, 23)
    $button3.Text = "Open in Browser"
    
    #$button3.Enabled = $false
    $button3.BackColor = 'White'
    $button3.add_Click{
                        Browse ($ipbox.Text);
                    }

    # GUI freeze warning
    $guil = New-Object System.Windows.Forms.Label
    $guil.Location = New-Object System.Drawing.Point(15,280)
    $guil.Size = New-Object System.Drawing.Size(300, 60)
    $guil.ForeColor = "White"
    $guil.BackColor = 'Black'
    $guil.Text = 'Warning - GUI will freeze during operations, Do not Panic and click to make it unresponsive.Howeverif you want to close this, Use Task Manager to kill it because we lack multithreading knowlegde at this point of time.'

    Clear-Host
    
    #Show defined GUI Dialog
    [void]$form1.showdialog()


}


#---------------Functions------------------------
function connect($esx, $user, $pass)
{
    Get-Module -Name VMware* -ListAvailable | Import-Module -ErrorAction Stop
    Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true
    $ConnectionObj = Connect-VIServer -Server $esx -User $user -Password $pass -ErrorAction SilentlyContinue -WarningAction SilentlyContinue; $?
    return $ConnectionObj
}

function Config($esx)
{
     $windows = 'Windows Server 2003','Windows Server 2008','Windows Server 2008 R2','Windows Server 2012','Windows Server 2012 R2', 'Windows Server 2016','Windows Server 2019','Windows 10','Windows 8.1','Windows 8','Windows Vista'
     $ds= Get-Datastore -Server $esx | where {$_.Name -notlike "NFS*" -and $_.CapacityGB -notlike "0*"}
     
     $Form1.Controls.Remove($luser)
     $Form1.Controls.Remove($lpass)
     $Form1.Controls.Remove($label)
     $Form1.Controls.Remove($tbuser)
     $Form1.Controls.Remove($tbpass)
     $Form1.Controls.Remove($Button)
     $Form1.Controls.Remove($cb1)
     $Form1.Controls.Remove($lwarn)
     $Form1.Controls.Remove($abtl)
     $Form1.Controls.Remove($tbst)
     $Form1.Controls.Remove($label2)
     $cb2.Items.Clear()
     $tbst.Text = ''
     $cb5.Items.Clear()
     $cb3.Items.Clear()
     $Form1.Controls.Add($button4)
     
     #Datastore population
     $cb2.Text = ''
     $ds | % {$cb2.Items.Add($_)}
     $cb2.add_SelectedValueChanged{
        $total = (Get-datastore | where {$_.Name -eq $cb2.Text} | select CapacityGB).CapacityGB
        $free = (Get-datastore | where {$_.Name -eq $cb2.Text} | select FreeSpaceGB).FreeSpaceGB
        $tbst.Text = 'Total - '+[math]::Round($total,2)+' G   |   Free - '+[math]::Round($free,2)+' G'
        }
     
     $option = 'Virtual Machine','Custom OVA'
     $option |   % {$cb5.Items.Add($_)} 
     $windows | % {$cb3.Items.Add($_)}
     $cb4.Enabled = $false
     $cb3.Enabled = $false
     $cb5.add_SelectedValueChanged{
     if($cb5.Text -eq 'Virtual Machine')
     {
        $cb3.Enabled = $true
        $cb4.Enabled = $true
        $cb3.Text = ''
        $cb4.Text = ''
        $lwin.Enabled = $true
        $lwin.Text = 'Windows'
        $ledi.Text = 'Edition'
        
        $cb3.add_SelectedValueChanged{
       
        if ($cb3.Text -eq 'Windows Server 2003'){
            $cb4.Text = 'Enterprise'
            $cb4.Enabled = $false
        }
        Elseif ($cb3.Text -eq 'Windows Server 2008'){
            $cb4.Enabled = $true
            $cb4.DataSource = 'Standard','Datacenter','Enterprise'
        }
        Elseif ($cb3.Text -eq 'Windows Server 2008 R2'){
            $cb4.Enabled = $true
            $cb4.DataSource = 'Standard','Datacenter','Enterprise','Web','HPC','Core' 
        }
        Elseif ($cb3.Text -eq 'Windows Server 2012'){
            $cb4.Enabled = $true
            $cb4.DataSource = 'Standard','Datacenter','Essential','Foundation','Core','EFI-GPT'
        }
        Elseif ($cb3.Text -eq 'Windows Server 2012 R2'){
            $cb4.Enabled = $true
            $cb4.DataSource = 'Standard','Datacenter','Essential','Foundation','Core','EFI-GPT'
        }
        Elseif ($cb3.Text -eq 'Windows Server 2016'){
            $cb4.Enabled = $true
            $cb4.DataSource = 'Standard','Datacenter','Essential','Core','EFI-GPT'
            }
        Elseif ($cb3.Text -eq 'Windows 10'){
            $cb4.Enabled = $true
            $cb4.DataSource = '64 Bit','32 Bit'
            }
        Elseif ($cb3.Text -eq 'Windows 8.1'){
            $cb4.Enabled = $true
            $cb4.DataSource = '64 Bit','32 Bit'
            }
        Elseif ($cb3.Text -eq 'Windows 8'){
            $cb4.Enabled = $true
            $cb4.DataSource = '64 Bit','32 Bit'
            }
        Elseif ($cb3.Text -eq 'Windows Vista'){
            $cb4.Enabled = $false
            $cb4.Text = '64 Bit'
            }
        Elseif ($cb3.Text -eq 'Windows Server 2019'){
            $cb4.Enabled = $true
            $cb4.DataSource = 'Standard','Datacenter'
            }
     }
     }
     Elseif($cb5.Text -eq 'Custom OVA')
        {
            $cb3.Enabled = $false
            $cb3.Text = 'Appliance'
            $lwin.Text = 'Type'
            $ledi.Text = 'Version'
            $cb4.Enabled = $true
            $cb4.DataSource = '10.3.2','10.3.1','10.3.0','10.2.0','10.1.1','10.1.0','10.0.0','9.2.0-4','9.1.2','9.1.1','9.0.0-15'

        }
     }
     
     $cbox1.Add_CheckStateChanged({
      If ($cbox1.Checked) 
        {
            $ctbox.Enabled = $true
            $ctbox.Text = '5'
        } 
      Else 
        {
            $ctbox.Enabled = $false
            $ctbox.Text = 'Size in GB'
        }
      })

      $ipbox.Add_TextChanged({
        
      $gtcollect = @('192.168.197.', '192.168.139.','192.168.192.','10.159.5.','192.168.200.' )
        
        foreach ($gt in $gtcollect)
        {
            if($ipbox.Text -ilike $gt)
                {
                    if($ipbox.Text -ilike '192.168.200.'){$gtbox.Text = $gt + '3'}
                    elseif($ipbox.Text -ilike '10.159.5.'){$gtbox.Text = $gt + '2'}
                    else{$gtbox.Text = $gt + '1'}
                }
            if($ipbox.Text -ilike '10.159.*')
                {
                    $dnsbox.DataSource = '10.151.3.17','192.168.59.25' 
                }
            else
            { $dnsbox.Datasource = '192.168.20.100','192.168.20.168','10.151.3.17','192.168.59.25' }
            
        } 
        })

     $Form1.Controls.Add($cb2)
     $Form1.Controls.Add($tbst)
     $Form1.Controls.Add($label2)
     $Form1.Controls.Add($cb3) 
     $Form1.Controls.Add($cb4) 
     $Form1.Controls.Add($vmname)  
     $Form1.Controls.Add($iplb)
     $Form1.Controls.Add($nb) 
     $Form1.Controls.Add($ipbox)
     $Form1.Controls.Add($labe2)
     $Form1.Controls.Add($lwin)
     $Form1.Controls.Add($ledi)
     $Form1.Controls.Add($gtbox)
     $Form1.Controls.Add($gtlb)
     $Form1.Controls.Add($dnsbox)
     $Form1.Controls.Add($dnslb)
     $Form1.Controls.Add($button2)
     $Form1.Controls.Add($cb5)
     $Form1.Controls.Add($ldep)
     $Form1.Controls.Add($cbox1)
     $Form1.Controls.Add($cboxl)
     $Form1.Controls.Add($ctbox)
}

function Set-IP($vmname, $ip, $gtw, $dns, $win, $edi, $depch)
{
     Write-Host "Name-$vmname, IP-$ip, Gateway-$gtw, DNS-$dns, Windows-$win, Edition-$edi, Depch-$depch"
     $vmsl.Text = 'Waiting for VM to get ready for IP set operations'
     $Form1.Controls.Add($vmsl)
    
     
     if($win -eq "Custom OVA")
     {
        Write-Host "Setting IP"
        $vmsl.Text = 'Waiting for custom OVA to get ready for IP set operations'
        Write-Host 'Waiting for custom OVA to get ready for IP set operations'
        Do 
            {
                $IsVMOperationReady = (Get-VM -Name $vmname).ExtensionData.guest.guestOperationsReady
                Start-Sleep -Seconds 5
            }Until($IsVMOperationReady -eq "False")

        $vmsl.Text = 'Starting configuration of custom OVA'
        $ipadd = "s/IPADDR=.*/IPADDR="+$ip+"/g"
        $cmd1 = "/bin/sed -i s/NM_CONTROLLED=.*/NM_CONTROLLED=no/g /etc/sysconfig/network-scripts/ifcfg-eth0"
        $cmd2 = "ex -sc '%s/10.10.10.1/"+$ip+"/g|x' /etc/hosts"
        $cmd3 = "service network restart"
        $cmd4 = "/bin/sed -i s/BOOTPROTO=.*/BOOTPROTO=static/g /etc/sysconfig/network-scripts/ifcfg-eth0"
        $cmd4 = "/bin/sed -i s/ONBOOT=.*/ONBOOT==yes/g /etc/sysconfig/network-scripts/ifcfg-eth0"
        $cmd5 = "/bin/sed -i "+ $ipadd+" /etc/sysconfig/network-scripts/ifcfg-eth0"
        $cmd6 = "/bin/sed -i s/NETMASK=.*/NETMASK=255.255.255.0/g /etc/sysconfig/network-scripts/ifcfg-eth0"
        $cmd7 = "/bin/echo GATEWAY="+$gtw+" >> /etc/sysconfig/network-scripts/ifcfg-eth0"
        $cmd8 = "/bin/echo DNS1="+$dns+" >> /etc/sysconfig/network-scripts/ifcfg-eth0"

        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd1 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd2 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd3 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd4 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd5 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd6 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd7 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd8 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue
        Invoke-VMScript -VM $vmname -ScriptType Bash -ScriptText $cmd3 -GuestUser root -GuestPassword Password -WarningAction Ignore -ErrorAction SilentlyContinue

        $Form1.Controls.Add($donel)
        $button3.Enabled = $true
        $Form1.Controls.Add($button3)
        
     } 
     Else
     {
        Do 
        {
            $IsVMOperationReady = (Get-VM -Name $vmname).ExtensionData.guest.interactiveGuestOperationsReady
            Start-Sleep -Seconds 20
            Write-Host "Is VM Ready ? - $IsVMOperationReady"

        }Until($a -eq "False")

        $vmsl.Text = 'VM is Ready'
        Write-Host 'VM is Ready'

        if($IsVMOperationReady -eq "True")
        {
            if($win -eq "Windows Vista")
                {
                    $username = 'Admin'
                    Write-Host "Found Vista OS, changing username to Admin"
                }
            Elseif($win-eq "Windows 8")
            {
                $username = 'Admin'
                Write-Host "Found Windows 8 OS, changing username to Admin"
            }
            else
            {  
                Write-Host "Using default account as Administrator"
                $username = 'Administrator'
            }

            $network = Invoke-VMScript -VM $vmname -ScriptType Powershell -ScriptText "(gwmi Win32_NetworkAdapter -filter 'netconnectionid is not null').netconnectionid" -GuestUser $username -GuestPassword Password
            $network1 = $network.Trim()
            Write-Host "Applying Network settings to $network1"
        
            #IP Set logic for Server 2003
            if($win -eq "Windows Server 2003")
            {
                $cmdIP = "netsh interface ip set address name=`"$network1`" static $ip 255.255.255.0 $gtw 1"
                $dnsset = "netsh interface ip set dns name=`"$network1`" static $dns primary"
                $adapoff = "netsh interface set interface name=`"$network1`" admin=disabled"
                $adapon = "netsh interface set interface name=`"$network1`" admin=enabled"
                Write-Host "Setting IP and Gateway.."
                Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $cmdIP -GuestUser $username -GuestPassword Password -WarningAction Ignore
                Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $dnsset -WarningAction Ignore -GuestUser $username -GuestPassword Password
                Write-Host "Resetting network adapter.."
                Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $adapoff  -WarningAction Ignore -GuestUser $username -GuestPassword Password
                Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $adapon  -WarningAction Ignore -GuestUser $username -GuestPassword Password
            return
        }

            $cmdIP = "netsh interface ipv4 set address name=`"$network1`" static $ip 255.255.255.0 $gtw"
            $dnsset = "netsh interface ipv4 set dns name=`"$network1`" static $dns"
            $adapoff = "netsh interface set interface name=`"$network1`" admin=disabled"
            $adapon = "netsh interface set interface name=`"$network1`" admin=enabled"
            $rdpon = 'reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f'
            Write-Host "Setting IP and Gateway.."
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $cmdIP -GuestUser $username -GuestPassword Password -WarningAction Ignore
            Write-Host "Setting DNS.."
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $dnsset -WarningAction Ignore -GuestUser $username -GuestPassword Password
            Write-Host "Resetting network adapter.."
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $adapoff  -WarningAction Ignore -GuestUser $username -GuestPassword Password
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $adapon  -WarningAction Ignore -GuestUser $username -GuestPassword Password
            Write-Host "Setting Network profile to Private.."
            Invoke-VMScript -VM $vmname -ScriptType Powershell -ScriptText "Set-NetConnectionProfile -NetworkCategory Private" -WarningAction Ignore -GuestUser $username -GuestPassword Password
            Write-Host "Making your password immortal.."
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText "WMIC USERACCOUNT WHERE Name='Administrator' SET PasswordExpires=FALSE" -WarningAction Ignore -GuestUser $username -GuestPassword Password
            Write-Host "Turning off firewall.."
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText "netsh advfirewall set allprofiles state off" -WarningAction Ignore -GuestUser $username -GuestPassword Password
            Write-Host "Turning on Remote Desktop.."
            Invoke-VMScript -VM $vmname -ScriptType Bat -ScriptText $rdpon -WarningAction Ignore -GuestUser $username -GuestPassword Password
     }
            else
            { Write-Host "Seems some issue with VMware tools on guest machine" }
            $Form1.Controls.Add($donel)
     }


     $Form1.Show()

     
}


function Deploy($ds1, $win, $edi, $depch, $name, $ip, $gtw, $dns, $esx)
{
     #Removing previous elements
     $Form1.Controls.Remove($vmname)  
     $Form1.Controls.Remove($iplb)
     $Form1.Controls.Remove($nb) 
     $Form1.Controls.Remove($ipbox)
     $Form1.Controls.Remove($labe2)
     $Form1.Controls.Remove($cb2)
     $Form1.Controls.Remove($cb3) 
     $Form1.Controls.Remove($cb4) 
     $Form1.Controls.Remove($lwin)
     $Form1.Controls.Remove($ledi)
     $Form1.Controls.Remove($button2)  
     $Form1.Controls.Remove($label3)
     $Form1.Controls.Remove($gtbox)
     $Form1.Controls.Remove($gtlb)
     $Form1.Controls.Remove($dnsbox)
     $Form1.Controls.Remove($dnslb)
     $Form1.Controls.Remove($cb5)
     $Form1.Controls.Remove($ldep)
     $Form1.Controls.Remove($cbox1)
     $Form1.Controls.Remove($cboxl)
     $Form1.Controls.Remove($ctbox)
     $Form1.Controls.Remove($button4)
     $Form1.Controls.Remove($mod)
     $Form1.Controls.Remove($label2)
     $Form1.Controls.Remove($tbst)

     #Making Form
     $Form1.Controls.Add($progl)
     $Form1.Controls.Add($guil)
     $Form1.SendToBack()

     $vmhost = Get-VMHost -Server $esx
     
     if($win -eq "Custom OVA")
     {  
       
        Write-Host "Deploying Custom OVA"
        Write-Host "Datastore-$ds1, Type-$win, Edition-$edi, Dep Choice-$depch, IP-$ip, Gateway-$gtw, DNS-$dns"
        $Form1.Controls.Add($depol)
        $t1 = Measure-Command{ switch ($edi)
        {
            10.3.2 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; Break}
            10.3.1 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; Break}
            10.3.0 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; Break}
            10.2.0 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; Break}
            10.1.1 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; Break}
            10.1.0 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force;Break}
            10.0.0 {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force;Break}
            9.2.0  {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force;Break}
            9.1.2  {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force;Break}
            9.1.1  {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force;Break}
            9.0.0  {$vmhost | Import-VApp -Source '\\share\custom.ova' -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force;Break}
        default {Write-Host "Select correct option";Break}
        }}
        
        #Adding default disk
        $vm = Get-VM -Name $name
        $vm | New-HardDisk -CapacityGB 200 -StorageFormat Thin
        $Form1.Controls.Add($addl)
        if($cbox1.Checked)
        {
            $addl.Text = 'Adding Disk..'
            $Form1.Controls.Add($addl)
            $vm = Get-VM -Name $name
            $vm | New-HardDisk -CapacityGB ($ctbox.Text) -StorageFormat Thin
        }
        
     }
     else
     {
        # VM Deployment section
        Write-Host "Deploying VM" 
        Write-Host "Datastore-$ds1, Type-$win, Edition-$edi, Dep Choice-$depch, IP-$ip, Gateway-$gtw, DNS-$dns, VM Name-$name" 

        if($win -eq "Windows Server 2003")
         {
            if($edi -eq "Enterprise"){$ch=0}
         }
        Elseif($win -eq 'Windows Server 2008' )
         {
            if($edi -eq 'Datacenter') {$ch=11}
            if($edi -eq 'Standard')   {$ch=12}
            if($edi -eq 'Enterprise') {$ch=13}
         }
        Elseif($win -eq 'Windows Server 2008 R2' )
         {
            if($edi -eq 'Datacenter') {$ch=21}
            Elseif($edi -eq 'Standard')   {$ch=22}
            Elseif($edi -eq 'Enterprise') {$ch=23}
            Elseif($edi -eq 'Web')        {$ch=24}
            Elseif($edi -eq 'HPC')        {$ch=25}
            Elseif($edi -eq 'Enterprise') {$ch=27}
         }
        Elseif($win -eq 'Windows Server 2012')
         {
            if($edi -eq 'Datacenter') {$ch=31}
            if($edi -eq 'Standard')   {$ch=32}
            if($edi -eq 'Essential')  {$ch=33}
            if($edi -eq 'Foundation') {$ch=34}
            if($edi -eq 'Core')       {$ch=35}
            if($edi -eq 'EFI-GPT')    {$ch=36}
         }
        Elseif($win -eq 'Windows Server 2012 R2')
         {
            if($edi -eq 'Datacenter') {$ch=41}
            if($edi -eq 'Standard')   {$ch=42}
            if($edi -eq 'Essential')  {$ch=43}
            if($edi -eq 'Foundation') {$ch=44}
            if($edi -eq 'Core')       {$ch=45}
            if($edi -eq 'EFI-GPT')    {$ch=46}
         }
        Elseif($win -eq 'Windows Server 2016')
         {
            if($edi -eq 'Datacenter') {$ch=51}
            if($edi -eq 'Standard')   {$ch=52}
            if($edi -eq 'Essential')  {$ch=53}
            if($edi -eq 'Core')       {$ch=54}
            if($edi -eq 'EFI-GPT')    {$ch=55}
         }
        Elseif($win -eq 'Windows 10')
         {
            if($edi -eq '64 Bit') {$ch=101}
            if($edi -eq '32 Bit') {$ch=102}
         }
        Elseif($win -eq 'Windows 8.1')
         {
            if($edi -eq '64 Bit') {$ch=811}
            if($edi -eq '32 Bit') {$ch=812}
         }
        Elseif($win -eq 'Windows 8')
         {
           if($edi -eq '64 Bit') {$ch=801}
           if($edi -eq '32 Bit') {$ch=802}
         }
        Elseif($win -eq 'Windows Vista')
         {
           if($edi -eq '64 Bit') {$ch=V}
         }
         Elseif($win -eq 'Windows Server 2019')
         {
           if($edi -eq 'Datacenter') {$ch=61}
           if($edi -eq 'Standard') {$ch=62}
         }
        
        
        if (test-connection $defip -Count 1 -ErrorAction SilentlyContinue ) 
                {
                    $ipv4 = $defip
                    $depsl.Text =  "Using "+$defip+" Server"
                    Write-Host "Using $defip Server for Deployement"
                    $Form1.Controls.Add($depsl)
                }
        Elseif(test-connection '192.168.139.181' -Count 1 -ErrorAction SilentlyContinue )
                {
                    $ipv4 = '192.168.139.181'
                    $depsl.Text =  "Switching to failover server"
                    Write-Host  "Switching to failover server for Deployement"
                    $Form1.Controls.Add($depsl) 
                }
        else{ Write-Host "Deployment is not not possible as no server is available for Deployment, therefore exiting the script"; Sleep 7; exit;}
        


        $Form1.Controls.Add($depol)
        
        $t1 = Measure-Command { switch($ch)
        { 
            0 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2003\testvm2003-3\testvm2003-3.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            11 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008\2008-DatacenterX64\2008-DatacenterX64.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}
            12 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008\2008-StandardX64\2008-StandardX64.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}
            13 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008\2008-EnterpriseX64\2008-EnterpriseX64.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}
            21 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008R2\2008R2-Datacenter-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            22 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008R2\2008R2-Standard-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            23 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008R2\2008R2-Enterprise-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            24 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008R2\2008R2-WebServer-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            25 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008R2\2008R2-HPC-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            27 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2008R2\2008R2-Core-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}
            31 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012\2012-datacenter.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            32 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012\2012-Standard.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            33 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\') -Name $name -Datastore $ds -DiskStorageFormat Thin -Force; 
                Break}
            34 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012\2012-Foundation.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            35 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012\2012-Core\2012-Core.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}
            36 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012\2012-EFI-DC\2012-EFI-DC.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            41 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\2012R2-DatacenterV-Gen8.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            42 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\2012R2-Standard.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            43 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\2012R2-Essential.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            44 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\2012R2-Foundation.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            45 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\2012R2-Core.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            46 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2012R2\2012R2-EFI-DC.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            51 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2016\2016-DC-Gen8\2016-DC-Gen8.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            52 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2016\2016-STD-Gen8\2016-STD-Gen8.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            53 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2016\2016-Essential-Gen8\2016-Essential-Gen8.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            54 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2016\2016-Core\2016-Core.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            55 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2016\2016-EFI-DC\2016-EFI-DC.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            61 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2019\Datacenter\2019-DC.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            62 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\2019\Standard\2019-STD1.ova') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            V  {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\Vista\testvista.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            101 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\10\Windows10x64\Windows10x64.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            102 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\10\Windows10x86\Windows10x86.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force 
                Break}
            811 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\8.1\81x64\81x64.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            812 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\8.1\81x86\81x86.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                Break}
            801 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\8\8x64\8x64.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}
            802 {$vmhost | Import-VApp -Source ('\\'+$ipv4+'\UAD\8\8x86\8x86.ovf') -Name $name -Datastore $ds1 -DiskStorageFormat Thin -Force; 
                (New-Object -ComObject Wscript.Shell).Popup("Please login into VM manually to continue IP set process after it boots up completly",0,"Important Message",0);
                Break}

    }}
        
        $Form1.Controls.Add($addl)
        if($cbox1.Checked)
            {
            $addl.Text = 'Adding Disk..'
            
            $vm = Get-VM -Name $name
            $vm | New-HardDisk -CapacityGB ($ctbox.Text) -StorageFormat Thin
            }
        
       
      
     }

     $Form1.Controls.Add($startl)
     Start-VM -VM $name
     $t2 = Measure-Command { Set-IP $name $ip $gtw $dns $win $edi $depch }
     Statistic ($cb1.Text) $name $ds1 $t1.TotalSeconds $t2.TotalSeconds $win $edi

  }   

  
function Statistic($esx,$name,$ds1,$t1,$t2,$Win,$edi)
{
    if($win -eq "Custom OVA")
    {
        $system = (Test-Connection -ComputerName $env:computername -count 1).IPV4Address.ipaddressTOstring
        $date = Get-Date -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        New-Object -TypeName PSCustomObject -Property @{
        CONFIGURATION_TIME = $t2
        DEPLOYEMENT_TIME = $t1
        DATE = $date
        SYSTEM = $system
        DATASTORE = $ds1
        VM_NAME = $name
        OS = "UEB "+$edi
        ESX = $esx
        } | Export-Csv -Path \\192.168.197.201\OVA\customova_deploy.csv -NoTypeInformation -Append -Encoding UTF8 -Delimiter ","
    }
    else
    {
        $system = (Test-Connection -ComputerName $env:computername -count 1).IPV4Address.ipaddressTOstring
        $date = Get-Date -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        New-Object -TypeName PSCustomObject -Property @{
        CONFIGURATION_TIME = $t2
        DEPLOYEMENT_TIME = $t1
        DATE = $date
        SYSTEM = $system
        DATASTORE = $ds1
        VM_NAME = $name
        OS = $win
        ESX = $esx
        } | Export-Csv -Path \\192.168.197.201\OVA\vmdeploy.csv -NoTypeInformation -Append -Encoding UTF8 -Delimiter ","
    }
    
}

function CheckIPAvailability($ip)
{
    if (test-connection $ip -Count 1 -ErrorAction SilentlyContinue ) { return $true }
    else { return $false }
}

function Browse($ip)
{
        function IsInstalled( $program ) {
    
                $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
                Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

                $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
                Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

                return $x86 -or $x64;
      }

        if((IsInstalled 'Google Chrome') -ilike 'True')
            {
                Start-process -FilePath 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' -ArgumentList $ip
            }
        Elseif((IsInstalled 'Mozilla Firefox') -ilike 'True')
            {
                Start-process -FilePath 'C:\Program Files\Mozilla Firefox\firefox.exe' -ArgumentList $ip
            }
        else
            {
                Start-process -FilePath 'C:\Program Files\Internet Explorer\iexplore.exe' -ArgumentList $ip
            }
            
    }


function About 
{
    $Form1.Controls.Remove($cb1)
    $Form1.Controls.Remove($tbuser)
    $Form1.Controls.Remove($tbpass)
    $Form1.Controls.Remove($Button)
    $Form1.Controls.Remove($label)
    $Form1.Controls.Remove($lpass)
    $Form1.Controls.Remove($luser)
    $Form1.Controls.Add($abttb)
    $Form1.Controls.Remove($abtl)
    $Form1.Controls.Remove($lwarn)
    $Form1.Controls.Add($abtl)
    $abtl.Text = "< Back"
    $Form1.Controls.Remove($mod)
    $abtl.add_Click({MainScreen})
    
    $abttb.Text =
    "
    Welcome to 
    ESX VM DEPLOYER (EVMD) 
    information page
    ------------------------------------
          
    Moto
    ---------
         
    This Scripts basically deploys Windows Server editions 
    (2003, 2008, 2008 R2, 2012, 2012R2 & 2016) and 
    Microsoft client editions like Windows 7, Windows 8, 
    Windows 8.1, Windows 10 with all x86 & x64 bit option
    on VMware ESX 5.5  and laterversion without having 
    need of Vcenter server. This script is written to minimize 
    the manual process of installing Windows OSes for 
    testing purpose.


    Requirements for Script to work
    --------------------------------------------------
         
    System should have PowerCLI 6.x installed and 
    powershell support. Recommended OS to use this script 
    is Server 2012 and later or Windows 10(tested).

         
    Default Specs of VM
    ----------------------------------
    Every VM deployed through this tool has following 
    configuration predefined-

    CPU- 2
    Memory- 4 GB (4096 MB)
    Main Disk- 100 GB Thin
    Network- Adapter VMXNET3 Type
    VM Generation - 8 


    Supported OS Edtitons
    ------------------------------------- 

    Windows Server Edition-

    * 2003 Enterprise Edtion SP2
    * 2008 (Datacenter, Standard, Enterprise)
    * 2008 R2 (Datacenter, Standard, Enterprise, Web, HPC, 
      Core)
    * 2012 (Datacenter, Standard, Essential, Foundation, 
      Core)
    * 2012 R2 (Datacenter, Standard, Essential, Foundation, 
      Core)
    * 2016 (Datacenter, Standard, Essential, Core) 

    Windows Client editions

    * Windows Vista Enterprise x64 Bit 
    * Windows 8.1 x86 & x64 Bit
    * Windows 10 x86 & x64 Bit


    In-progress OS Editions
    -------------------------------------

    * Windows 7
    * Windows 8
       

    Features
    --------------

    * Automatically installs PowerCLI on your system if it is not 
      already installed.
    * Deploys VM on any reachable ESX server
    * Sets IP & other network setting on VM.
    * Enables Remote Desktop.
    * Turns off firewall.
    * Make password never expiring (experimental)



    Basic issues that can be fixed with small effort
    -------------------------------------------------------------------------

    1. If you face any share related error while running script. 
       Please access // 192.168.197.181/uad and
       //192.168.139.181/uad share with credentials 
       (Administrator/Password) if asked. Once creds are
       provided, the script should be able to access share
       to get deployment templates.

    2. Can not connect to ESX on main screen - Make sure 
       that all PowerCLI modules are loaded at the start
       of script where you can see its loading a list 
       of module.Script will only work if all modules
       are loaded properly    

         
         
         "
         
         
}

function MainScreen
{
    $Form1.Controls.Remove($abttb)
    $Form1.Controls.Remove($vmname)  
    $Form1.Controls.Remove($iplb)
    $Form1.Controls.Remove($nb) 
    $Form1.Controls.Remove($ipbox)
    $Form1.Controls.Remove($labe2)
    $Form1.Controls.Remove($cb2)
    $Form1.Controls.Remove($cb3) 
    $Form1.Controls.Remove($cb4) 
    $Form1.Controls.Remove($lwin)
    $Form1.Controls.Remove($ledi)
    $Form1.Controls.Remove($gtbox)
    $Form1.Controls.Remove($gtlb)
    $Form1.Controls.Remove($dnsbox)
    $Form1.Controls.Remove($dnslb)
    $Form1.Controls.Remove($button2)
    $Form1.Controls.Remove($cb5)
    $Form1.Controls.Remove($ldep)
    $Form1.Controls.Remove($cbox1)
    $Form1.Controls.Remove($cboxl)
    $Form1.Controls.Remove($ctbox)
    $Form1.Controls.Remove($button4)
    $Form1.Controls.Remove($tbst)
    $Form1.Controls.Remove($label2)
    $cb2.Items.Clear()
    $cb5.Items.Clear()
    $cb3.Items.Clear()
    $Form1.Controls.Add($abtl)
    $abtl.Text = "About "
    $abtl.add_Click({ About })
    $Form1.Controls.Add($cb1)
    $Form1.Controls.Add($tbuser)
    $Form1.Controls.Add($tbpass)
    $Form1.Controls.Add($lpass)
    $Form1.Controls.Add($luser)
    $Form1.Controls.Add($label)
    $Form1.Controls.Add($lwarn)
    $Form1.Controls.Add($Button)

}

LaunchApp


























