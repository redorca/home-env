#!/bin/bash


#
# Install the home environment
#
clone-env()
{
        mkdir bin
        pushd bin >/dev/null
        git clone https://github.com/redorca/home-env.git
        python3 home-env/bin/mkhome.py
        popd >/dev/null

        return 0
}

#
# The set of packages known to underpin my work.
#
install-pkgs()
{
        pushd Documents >/dev/null
        sudo apt-get -y install $(cat requirements.home-env.txt)
        popd >/dev/null

        return 0
}

#
# Other apps that are not part of a repo.
#
install-other()
{
        pushd Downloads >/dev/null
        sudo dpkg -i *.deb
        sudo tar -C /opt -Jxf waterfox-G4.1.3.2-libs.tar.xz
        sudo tar -C /opt -Jxf waterfox-G4.1.3.2-dirs.tar.xz
        popd >/dev/null

        pushd /usr/bin >/dev/null
        sudo ln -sf /opt/waterfox/waterfox waterfox
        popd >/dev/null

        return 0
}

#
# check whether the guest additions image is mounted and run if so
#
install-guest-stuff()
{
        if [ -z "$(find /media/$(hostname)/ -type f -name VBoxLinuxAdditions.run)" ] ; then
                echo "No guest additions media found." >&2
                return 0
        fi
        sudo $(find /media/$(hostname)/ -type f -name VBoxLinuxAdditions.run)
        eject /dev/sr0

        return 0
}

#
# Populate ssh keys
#
populate-keys()
{
        mkdir -p ${HOME}/.ssh
        pushd ${HOME}/.ssh > /dev/null

        cat <<EOF > id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
EOF
chmod ugo-rwx id_rsa
chmod u+r id_rsa

        cat <<EOF > id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNcK3+remnmOtSjui7qvF9VlmM8AdF6yYKxc2UcrQzmau62PRCuiFl7WRjF9vKF1KsOZ1VVSlbaXhJshfEGeUyABLaBMJXqFxCsvcehxi7Zg/Wc5HFJ1BzcSI/lgCxCkalxE+vIMSfkFXxFUmYirB/zeKRlaKXlimwa6GuYxU3T16izutspcE6CMcXuEM3UtaO9HuVd8zcLmBSA3kH/L47fALnNVQmGzmTk6Bp9rkZzG7RQ1kdcosaO9ZMRm6xP4Zl85DCbq4qbN3FSiqEYmh+GHOKb0LYKxkPgGa/QiP3LhZS/CmdHuLmyW4Vin13z6Y4aSuw8lo/oGlQnCmLDagG5M0xVNf1X024QAsmLVnCECQGyhwVqIhFGzjGJSzFpV8nJNVgpbbJDtInr78WKXc2/ieqCzkv1MXEk1MSx1n8B9kU5Ox21sUaTZuj3Rbq1w/N0yceAImnQH3Ni9nkdcckPwFzwo80HpPo8HByVNgUN4LIch8Ci2/LEzyKtj+jKLs= Bill@LAPTOP-6HBP8HGN
EOF
chmod ugo-rwx id_rsa.pub
chmod u+r id_rsa.pub

        popd >/dev/null

}

#
# Share my home directory as a guest
#
fixup-smbconf()
{
        ConfFile=/etc/samba/smb.conf
        sudo sed -i -e '/^\[/,/^$/s/^/;/' ${ConfFile}
        sudo sed -i -e '/^;\[home/,/^$/s/^;//' ${ConfFile}
        sudo sed -i -e '/^  *brows/d' ${ConfFile}
        sudo sed -i -e '/^  *map to/a   guest account = '${USER}'' ${ConfFile}
        sudo sed -i -e '/^\[hom/a read only = no' ${ConfFile}
        sudo sed -i -e '/^read/s/^/   /' ${ConfFile}
        sudo sed -i -e '/^\[hom/a guest ok = yes' ${ConfFile}
        sudo sed -i -e '/^guest/s/^/   /' ${ConfFile}
        sudo sed -i -e '/^\[hom/a browseable = yes' ${ConfFile}
        sudo sed -i -e '/^brow/s/^/   /' ${ConfFile}
        sudo sed -i -e '/^\[hom/a path = '${HOME}'' ${ConfFile}
        sudo sed -i -e '/^path/s/^/   /' ${ConfFile}

}

sudo hostname  $(hostname | sed -e 's/.VirtualBox//')
echo "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" > ${USER}
chmod ugo-wx ${USER}
chmod go-r ${USER}
sudo cp ${USER} /etc/sudoers.d
rm -f ${USER}

pushd ${HOME}/.local >/dev/null

if ! clone-env ; then echo "clone failed." >&2 && exit 1 ; fi
if ! install-pkgs ; then echo "install pkgs failed." >&2 && exit 1 ; fi
if ! install-other ; then echo "Other apps did not install." >&2 && exit 1 ; fi
if ! install-guest-stuff ; then echo "guest stuff did not install." >&2 && exit 1 ; fi

populate-keys
fixup-smbconf

popd >/dev/null

