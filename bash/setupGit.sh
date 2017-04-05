#!/bin/bash

# if Unity nfs mount is present
if (file Unity |grep symbolic)
then
	rm -f emulatorSetup.sh
	ln -s ~/Unity/emulatorSetup.sh emulatorSetup.sh
fi


# install git
yum install -y git-all.noarch

idStr='-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA0m0AEhXLWHI4SIAbp4Pd6wDAuAsFW7P+HmjAhNzl1zAILEwy
jsKwLNGo24QMhS89e2zSK8dDYG5Sgau6sRwMaa1BGYgi8R0HYlXEE/vMgkHL+X+C
+4K2d7YzEhXjTRQA0jXpAn6oOpKAECMv0dSYfG2FbxkLO4WAOKVRaPoXcAB2VmNX
8eWSRY74Th42K18uSO+ekOymfjcQ6JzUxy3i/Tl+LDZWzXtQvjkL4cWLgLhd5nGv
B94Syf5pifYbkBIjPpU4uQCmuYFPkZo0MObFadWsVTwsrE7GNFkTd0lmENGAYjn1
jCa31lpBCeqSFRa0RTwEFG3zyNEhcNCkEHLWvwIBIwKCAQEAzGniz71mcy0gu3Ui
LbNMmyVNf5WtbwafFjnflwJ436sAoA+Bkf70SMurWOatE6o7uborQHhtVlyKqdoF
0J7nfJms9DsaoRTimgosMKt2NWR9AP+GjeyxQRdkz719uJcWvZN0o1Z3iVsdUYFE
ZW9vjtDKw7Htp4kANwb+oH3q4dLMgjnlRudXuNxX28r4WttbzRjMZjWdXUwEdrCZ
ZVDkzZsA+Ul9rji7aqNkUaEXZvn2sS8XEpiGlQdSf3KyyROKCfrmh0Abt/XOi3no
hKhfSGGCrOZEYBplKqqThJ/VI+ZxiUqcF1a4FfDsIJbe/TsJPhpo60XENXZveyTi
XsBPOwKBgQD2GJrv8l+hVE+7CqDmtB204XwOpibOQ817ojrUcsAVAYWu+Kmddgcf
299I/uKAASxpH1tAIznKOd3JQGU3fvIU45sWBLvodvst2q/qs3Mrr6k+yQIQNh1N
mAts4mMfMQsKNhI1qK/b2a8tyLTq8uWn4E4CBpwGidacVDgazxvhUwKBgQDa5Ocp
J3mtOnqId9IEgyNtufgm6vgQlptUcdlibCIPoIUwFNAhYFfobQvqrPlzaF121HUE
UX++BcZD1W2kfl7EBWjL+90aMlRjrt28A/Nz4Jrff+Oo5hZMtCWWQRSRHLOX4pcu
Q+jiQG9NW+Wjd92wDmlo32R2FwCZ4Zg20L4rZQKBgBUYDUfEUVb4mR6pI7wAz1il
nOtQEfRsNi8rKZ0uaDxQlm4VUF30LH8S2J/bVT4r/H4KAIHXIjXns+ytv4hp934i
IzxmzkcgJCiAdXqEaPUdr2vIFh6ljXut8lnKQwKsbqkak9i2r/zmxd9aWKZsl1eI
QTNfpvk/A8RBu6qGx+AdAoGASwynBsu0sGvSPWro65qtD615pvF5n0mUV3d9u1hG
MT5ZjNPvlmosxLesUHXR3mzs2EjXqbWK4hCbv3xgGyQDO+SY9XrsuIZI0bhMBfK5
3pYmeIOegw0O9bobg/kOXaNwxlxRFy055ywI51K1Ihp35Jc6FVPn7flCCN+h5uh7
txsCgYEAzofZDXujZGQHPgd0Y882HJT7FINnlGyowTD/GTqnyULH/CwKVZsL4XiH
WGa564nJsL1WXZUcu1N1QJRkuQ79CTITQ8+RFjjzo2qEuNjraQM+EyvqxI4qztP/
WnAa5LGIQDrB8bpx7gdMzMClvwM+CWpZ2CGxpBotYrWVIUolwek=
-----END RSA PRIVATE KEY-----'

sshconfig='Host ibgit
        Hostname ibgitftc.usa.hp.com
	User git
	IdentityFile ~/.ssh/id_rsa_mwroberts'

echo "${sshconfig}" >> ~/.ssh/config
echo "${idStr}" > ~/.ssh/id_rsa_mwroberts
chmod 644 ~/.ssh/config
chmod 400 ~/.ssh/id_rsa_mwroberts

git config --file $PWD/gitconf user.name "Michael Roberts"
git config --file $PWD/gitconf user.email "michael.roberts@hp.com"

mkdir -p /root/mwroberts
cd /root/mwroberts
git clone git@ibgit:pml-hpsmb


