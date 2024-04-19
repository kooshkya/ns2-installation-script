#!bin/bash

clean_up_tcl() {
    cd ~
    rm -rf tcl8.5.10-src.tar.gz
    rm -rf tcl8.5.10
}

clean_up_tk() {
    cd ~
    rm -rf tk8.5.10-src.tar.gz
    rm -rf tk8.5.10
}

apt_update() {
    echo "Updating apt repositories..."
    sudo apt-get -y update > /dev/null

    if [ $? -ne 0 ] 
    then
        echo "Updating apt repositories failed with status $?"    
        exit 1
    fi

    echo "Apt update successful"
}


do_tcl() {
    echo "Downloading TCL 8.5.10 source..."
    wget -nv -O tcl8.5.10-src.tar.gz https://sourceforge.net/projects/tcl/files/Tcl/8.5.10/tcl8.5.10-src.tar.gz/download
    if [ $? -ne 0 ]
    then
        echo "Download failed, exiting..."
        exit 1
    fi
    echo "Download successful"
    echo "Untarring tcl 8.5.10..."
    tar xzf tcl8.5.10-src.tar.gz
    if [ $? -ne 0 ]
    then
        echo "Untarring failed, exiting..."
        exit 1
    fi

    cd tcl8.5.10/unix
    echo "configuring tcl 8.5.10..."
    ./configure > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Configuration of tcl 8.5.10 failed, exiting..."
        clean_up_tcl
        exit 1
    fi
    echo "successfully configured tcl 8.5.10"

    echo "making tcl 8.5.10..."
    make > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Make of tcl 8.5.10 failed, exiting..."
        clean_up_tcl
        exit 1
    fi
    echo "make of tcl 8.5.10 successful"
    
    echo "installing tcl 8.5.10..."
    sudo make install > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Installation of tcl 8.5.10 failed, exiting..."
        clean_up_tcl
        exit 1
    fi
    echo "Installation of tcl 8.5.10 successful"
    echo "removing tar for tcl 8.5.10"
    cd ../..
    rm -rf tcl8.5.10-src.tar.gz
    echo "removal successful"
    echo "tcl installed"
}


do_tk() {
    echo "Downloading tk 8.5.10 source..."
    wget -nv -O tk8.5.10-src.tar.gz https://sourceforge.net/projects/tcl/files/Tcl/8.5.10/tk8.5.10-src.tar.gz/download
    if [ $? -ne 0 ]
    then
        echo "Download failed, exiting..."
        exit 1
    fi

    echo "Untarring tk 8.5.10..."
    tar xzf tk8.5.10-src.tar.gz
    if [ $? -ne 0 ]
    then
        echo "Untarring failed, exiting..."
        exit 1
    fi

    echo "Installing prerequisites..."
    sudo apt-get -y install libx11-dev > /dev/null
    if [ $? -ne 0 ]
    then
        echo "installing libx11-dev failed, exiting"
        exit 1
    fi

    echo "Installation of libx11-dev successful"

    cd tk8.5.10/unix
    echo "Configuring tk 8.5.10"
    ./configure > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Configuration of tk 8.5.10 failed, exiting..."
        clean_up_tk
        exit 1
    fi
    echo "successfully configured tk 8.5.10"

    echo "making tk 8.5.10..."
    make > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Make of tk 8.5.10 failed, exiting..."
        clean_up_tk
        exit 1
    fi
    echo "make of tk 8.5.10 successful"
    
    echo "installing tk 8.5.10..."
    sudo make install
    if [ $? -ne 0 ]
    then
        echo "Installation of tk 8.5.10 failed, exiting..."
        clean_up_tk
        exit 1
    fi
    echo "Installation of tk 8.5.10 successful"
    echo "removing tar for tk 8.5.10"
    cd ../..
    rm -rf tk8.5.10-src.tar.gz
    echo "removal successful"
    echo "tk installed"
}

do_tclcl() {
    wget -O tclcl-src-1.20.tar.gz https://sourceforge.net/projects/otcl-tclcl/files/TclCL/1.20/tclcl-src-1.20.tar.gz/download
    tar xzf tclcl-src-1.20.tar.gz 
    cd tclcl-1.20/
    ./configure --with-tcl-ver=8.5.10
    make
    sudo make install
    cd ..
    rm -rf tclcl-src-1.20.tar.gz
}

do_otcl() {
    sudo apt-get -y install xorg-dev > /dev/null
    wget -nv -O otcl-src-1.14.tar.gz https://sourceforge.net/projects/otcl-tclcl/files/OTcl/1.14/otcl-src-1.14.tar.gz/download
    tar xzf otcl-src-1.14.tar.gz
    cd otcl-1.14/
    ./configure --with-tcl-ver=8.5.10 --with-tk-ver=8.5.10
    sed -i 's/-I\/users\/'"$USER"'\/tcl8\.5\.10\/generic/-I\/users\/'"$USER"'\/tcl8\.5\.10\/generic -I\/users\/'"$USER"'\/tcl8\.5\.10\/unix/g' Makefile
    make
    sudo make install
    cd ..
    rm -rf otcl-src-1.14.tar.gz
}

do_ns() {
    wget -nv -O ns-src-2.35.tar.gz https://sourceforge.net/projects/nsnam/files/ns-2/2.35/ns-src-2.35.tar.gz/download
    tar xzf ns-src-2.35.tar.gz 
    cd ns-2.35/
    ./configure --with-tcl-ver=8.5.10 --with-tk-ver=8.5.10
    git apply ../changes.patch
    make
    sudo make install
    if [ ! -e "/usr/local/lib/libotcl.so" ]; then
        sudo ln -s /users/"$USER"/otcl-1.14/NONE/lib/libotcl.so /usr/local/lib/libotcl.so
    fi
    sudo ldconfig
}

cd ~
apt_update
do_tcl
do_tk
do_otcl
do_tclcl
do_ns

exit 0