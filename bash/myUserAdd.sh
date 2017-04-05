#!/bin/bash

#
# e6s14 has uid=2001 and gid=2001 for mwroberts, if available can add
# --uid 2001 and --gid 2001 to useradd command
#
UxUser='mwroberts'
UxHome='/home'
UxShell='/bin/bash'
CONF='config_'${UxUser}
PRIKEY='id_rsa_'${UxUser}
PUBKEY=${PRIKEY}'.pub'
UserName='Michael Roberts'
UserEmail='Michael.Roberts@hp.com'
SshDir='.ssh'

if [[ ${1} = [rR] ]]
then
	##
	## As root
	##
	useradd -b ${UxHome} -c "${UserName}" -d ${UxHome}/${UxUser}\
	-m -s ${UxShell} ${UxUser}
	passwd ${UxUser}
else 
	##
	## As mwroberts
	##
	cd ${UxHome}/${UxUser}
	mkdir ${SshDir}
	cd ${SshDir}
	## registered with git
	 cat > ${PRIKEY} << 'eof'
	-----BEGIN RSA PRIVATE KEY-----
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
	-----END RSA PRIVATE KEY-----
eof
	cat > ${PUBKEY} << 'eof'
	ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0m0AEhXLWHI4SIAbp4Pd6wDAuAsFW7P+HmjAhNzl1zAILEwyjsKwLNGo24QMhS89e2zSK8dDYG5Sgau6sRwMaa1BGYgi8R0HYlXEE/vMgkHL+X+C+4K2d7YzEhXjTRQA0jXpAn6oOpKAECMv0dSYfG2FbxkLO4WAOKVRaPoXcAB2VmNX8eWSRY74Th42K18uSO+ekOymfjcQ6JzUxy3i/Tl+LDZWzXtQvjkL4cWLgLhd5nGvB94Syf5pifYbkBIjPpU4uQCmuYFPkZo0MObFadWsVTwsrE7GNFkTd0lmENGAYjn1jCa31lpBCeqSFRa0RTwEFG3zyNEhcNCkEHLWvw== mwroberts@e6s14
eof
	cat > ${CONF} << 'eof'
    Host ibgit
        Hostname ibgitftc.usa.hp.com
        User git
        IdentityFile ~/.ssh/id_rsa_mwroberts
eof

# Old server
#	cat > ${CONF} << 'eof'
#	Host swdnasgit ibgitftc.usa.hp.com
#	    Hostname 16.125.127.85
#	    IdentityFile ~/.ssh/id_rsa_mwroberts
#eof

	chmod 600 ${PRIKEY}
	chmod 644 ${PUBKEY}
	echo -e "Move ${CONF} to ~/.ssh/config before trying git commands"

	# git stuff
	#
	cd
	echo -e "Next steps:
	git config --global user.name \"${UserName}\"
	git config --global user.email \"${UserEmail}\"
	git clone git@ibgitftc:vdsi"

	#git add crr
	#git status
	#git commit
	#
fi
