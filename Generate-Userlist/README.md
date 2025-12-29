## Generate username list for the active directory valid username finding !

```bash
└─# ./GenUser_list.sh -h 
*****************************************
*           GenUser_list.sh             *
*****************************************
Usage: ./GenUser_list.sh -i input_user.lst
```
## usage
```bash
./GenUser_list.sh -i users.txt
*****************************************
*           GenUser_list.sh             *
*****************************************
[*] Creating Directory...
[*] Generating username variations...
[*] You can run the following command for further processing:

for i in users/var_user*.lst; do kerbrute userenum -d DOMAIN.LOCAL --dc 10.10.10.10 "$i"; sleep 3; done | grep -i "VALID USERNAME"

[*] Finished.
```
