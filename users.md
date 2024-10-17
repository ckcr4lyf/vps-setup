# Setting up users / SSH

Assuming a newly provisioned VPS with root (and ubuntu).

We will create an `ubuntu` user, disable password login, and add an allowed SSH key

## Disabling password auth

Edit `nano /etc/ssh/sshd_config` and change:

```
# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
```
to
```
# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
```

And then restart SSH:

```
systemctl restart ssh
```

## Create ubuntu user and add SSH key

As root:
```
adduser ubuntu
(complete all steps, enter random password for now)
```

Then
```
cd /home/ubuntu/
mkdir -p .ssh
cd .ssh
curl https://github.com/ckcr4lyf.keys >> authorized_keys
```

And now you can SSH into the VPS as ubuntu with your SSH key!

## Allow sudo without password

In the root shell, execute `visudo`, then at the bottom of the file, add:

```
ubuntu ALL=(ALL) NOPASSWD: ALL
```