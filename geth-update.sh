#!/bin/bash
#######################
# Get actual Linux binaries 64Bit - Geth with all tools
# Autor: gery@net6.at
# Donations:
# ETH: 0x9bc97c1f83d023dabc6168930169b2b386aef876


## Path or put script into dir where tgz and geth dir is present.
path=`pwd`

## test for latest version and grep the tag_name
test_version_check=`curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest |tac |tac |sed 's/[{}:",]//g' |egrep "tag_name" |head -n 1 |awk '{print $2}'`
# grep the latest release id
latest_id=`curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest |tac |tac |sed 's/[{}:",]//g' |egrep "id" |head -n 1 |awk '{print $2}'`
# check for latest commit and use the first 8 chars to build the download ID
commit_id=`curl -s https://api.github.com/repos/ethereum/go-ethereum/commits/$test_version_check |tac |tac |grep commit |grep url |head -n 1 |sed 's/[",:]//g' |sed 's,https//api.github.com/repos/ethereum/go-ethereum/git/commits/,,' |awk '{print $2}'`

# Build version without starting "v" AND build the 8 chars download id
latest_version=${test_version_check:1}
download_id=${commit_id:0:8}

# build download_url
download_url="https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-$latest_version-$download_id.tar.gz"
file=`echo $download_url |sed 's,/, ,g' |awk '{print $4}'`
url=`echo $download_url |sed 's,/'$file',,'`
dir=`echo $file |sed 's,.tar.gz,,'`
application=`echo $file |sed 's,-, ,' |awk '{print $1}'`


####
sym_link_check=`ls -l|grep "$application -> $dir"`
old_sym=`ls -l|grep "$application -> "`
echo "DEBUG"
echo "SYM_CHECK: $sym_link_check"
echo "OLD_SYM: $old_sym"
## info screen
echo ""
echo "$application install/update script"
echo "===================================="
echo "Application: $application"
echo "Latest Version: $latest_version"
echo "Release ID: $latest_id"
echo "Commit ID: ${commit_id:0:8}"
echo "===================================="
echo "Download File: $file"
echo "Download-URL: $url"
echo "Download-LINK: $download_url"
echo "===================================="
echo ""
cd $path
if [ -d "$dir" ]; then
echo "You have the latest version installed."
echo "Checking Symlink.."
if [ -z "$sym_link_check" ]; then
echo "Sym link missing to $latest_version"
if [ -z "$old_sym" ]; then
echo "No Sym Link Found -> Create a new Sym Link"
ln -s $dir/ ./$application
else
echo "OLD Sym Link found!"
echo "Unlinking the old sym link .."
unlink $application
ln -s $dir/ ./$application
echo "Sym link recreated to actual version"
fi
else
echo "Sym link is OK .. Exiting $0"
exit 1
fi
else

echo "Download $file ($application v$latest_version)and unpack to $path/$dir"
echo "==========================================================="
cd $path
curl -s $download_url | tar xvz
echo "==========================================================="
echo "Download of $application with version: $latest_version done."

echo ""
echo "Check if sym link of $application exists ..."
if [ -d "$application" ]; then
echo "Old Link exists, update to new version."
unlink $application
ln -s $dir/ ./$application
else
echo "No Link exists, looks like a fresh installation."
ln -s $dir/ ./$application
fi
echo "============================================="
echo "Sym link updated to:"
ls -al $application
echo "============================================="
echo "$application is installed now and ready to use with .$path/$dir/$application"
echo ""
echo ""

echo "INSTALL REPORT"
echo "============================================="
echo "$application v$latest_version has been successfully installed"
echo "Installpath: $path/$dir/"
echo "Available over symlink: $path/$application/"
echo "Start_command: .$path/$application/$application"
echo "============================================="

fi
exit 0
