# My `setup.sh`

![Screenshot](screenshot.png)

> [!IMPORTANT]
> Currently supports fresh standard installations of Debian >= 13 and Ubuntu Server >= 24.04

Run the following command as the user for whom you wish to perform the setup:
```
su -c "wget -qO- https://s.id/setup-sh | sh -s $USER" -
```
The username will be taken as an argument and the script will run after switching to the root user, for which the root password will be asked.

If no root password is set but sudo is available, prefix the above command with `sudo`.

If there is only one user (besides root), `$USER` can be omitted from the command. The setup will be done for the first non-root user found.

Similarly, to update the install, just run the command with `update-sh` instead, like
```
su -c "wget -qO- https://s.id/update-sh | sh -s $USER" -
```
