# Usage
This is bash script that call the ffuf to enumerate the subdomains.

## Why is here
I always mixed up the syntax of ffuf. Here is simple one.

```bash
bash Fast_ffuf.sh 10.10.10.10 /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt https://10.10.10.10/ 23
```
