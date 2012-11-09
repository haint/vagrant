This tool uses the ssh protocol to commit to the local git repository and deploy WAR to Vagrant's Tomcat.
But the script to run tool work only on Linux system.
And make sure you installed Vagrant tool :-)

You should use RSA public key to configure to run srcipt without password:

[local]$ ssh-keygen
[local]$ scp -P 2222 ~/.ssh/id_rsa.pub vagrant@localhost:/home/vagrant
[local]$ ssh vagrant@localhost:2222
# by default the password is "vagrant"
[vagrant]$ cat /home/vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

So after that enjoy my tool by :-)

[local]$ vagrant up
[local]$ ./scripts/run.sh

