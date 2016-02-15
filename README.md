TMT Common Software Vagrant setup
=================================

This repository has ansible scripts to provision Centos 7.1 linux with all the software required to run CSW. This also has a vagrant box which can be run on any developer machine.
Following software packages are required for csw. 

 hornetq-2.4.0.Final-bin.tar.gz
 jdk-8u73-linux-x64.tar.gz
 sbt-0.13.8.tgz
 scala-2.11.6.tgz
 zeromq-2.1.11.tar.gz
 Redis

Note that, as of now, binaries are copied into this repo, just to avoid downloads, in case you need to create box multiple times. It helps if you have slower internet speeds. It can be moved out later.

All this is automatically installed on the vagrant virtual box with Ansible.
The virtual machine is bento/centos-7.1.


Build Instructions
------------------

To use vagrant box for csw. You need to make sure that csw-vagrant is checked out and is sibling of other csw repositories.
e.g. If you have all csw repositories checked out in folder say ~/work it should look like following

```
 -work
   |
   -- csw
   |
   -- csw-pkg-demo
   |
   -- csw-play-demo
   |
   -- csw-vagrant 
```
As shown above, csw-vagrant needs to be the sibling of csw, csw-pkg-demo and csw-play-demo projects. Make sure to checkout all these projects before starting vagrant box.
Follow these instructions to start using the vagrant box.

* Install latest version of vagrant from https://www.vagrantup.com/. (Make sure you have the latest version)
* Open terminal window
* cd csw-vagrant
* type command 'vagrant up'. This will start the Centos-7.1 virtual box. 
* For the first time following steps will happen and it will take some time depending on your internet connection speed.
 * It will download bento/centos-7.1 virtual box image
 * After downloading, it will start the virtual machine.
 * After the startup is complete, it will start installing ansible on the virtual machine. Installing Ansible takes a while
 * After Ansible installation is complete, it will start provisioning the virtual machine with required software.
 * The provisioning output should look like following.
 
```
PLAY [all] ******************************************************************** 

GATHERING FACTS *************************************************************** 
ok: [default]

TASK: [Unarchieve SBT] ******************************************************** 
ok: [default]

TASK: [Explode JDK tar] ******************************************************* 
ok: [default]

TASK: [Setup Java binaries] *************************************************** 
changed: [default]

TASK: [Setup Javac binaries] ************************************************** 
changed: [default]

TASK: [Setup Jar binaries] **************************************************** 
changed: [default]

TASK: [Install EPEL repo required for redis] ********************************** 
ok: [default]

TASK: [Get Dependencies For ZeroMQ 2.1.11] ************************************ 
ok: [default] => (item=uuid-devel,pkgconfig,libtool,gcc-c++,libuuid-devel)

TASK: [Check if  zeromq is already installed] ********************************* 
ok: [default]

TASK: [Explode ZeroMQ Code] *************************************************** 
skipping: [default]

TASK: [Install ZeroMQ] ******************************************************** 
skipping: [default]

TASK: [Install EPEL repo required for redis] ********************************** 
ok: [default]

TASK: [yum name=redis] ******************************************************** 
ok: [default]

TASK: [yum name=libaio] ******************************************************* 
ok: [default]

TASK: [Check if  HornetQ is already installed] ******************************** 
ok: [default]

TASK: [Explode HornetQ] ******************************************************* 
skipping: [default]

TASK: [Rename the HornetQ directory] ****************************************** 
skipping: [default]

TASK: [unarchive scala] ******************************************************* 
ok: [default]

TASK: [Unarchieve SBT] ******************************************************** 
ok: [default]

TASK: [Creates .ivy directory] ************************************************ 
ok: [default]

TASK: [Explode ivy cache with all the dependecies] **************************** 
changed: [default]

TASK: [Give correct permissions] ********************************************** 
ok: [default]

TASK: [Put LD_LIBRARY_PATH for zeromq] **************************************** 
ok: [default]

TASK: [Put scala and sbt in path] ********************************************* 
ok: [default]

TASK: [Start redis] *********************************************************** 
ok: [default]
```
 * After the provisioning is complete, you can start using the box. Provisioning is a one time activity and it wont happen again and again.
 * You can login to virtual box with command `vagrant ssh`
 * All csw folders are mapped to virtual machine as following
 ```
 csw -> /vagrant/csw
 
 csw-pkg-demo -> /vagrant/csw-pkg-demo
 
 csw-play-demo -> /vagrant/csw-play-demo
 
 ```
 * The vagrant box has IP address 192.168.33.10. So you have to make sure Actor systems runs with this IP address.
 * In csw-pkg-demo/assembly1/src/main/resources/application.conf 
 ```
 remote {
 
    log-remote-lifecycle-events = off
 
    enabled-transports = ["akka.remote.netty.tcp"]
 
    netty.tcp {
 
      hostname = "192.168.33.10"
 
      port = 0
 
    }
 
  }
 ```
 * Add hostname entry to **/csw-pkg-demo/hcd2/src/main/resources/reference.conf
 ```
 akka {
    log-dead-letters = 0
    loglevel = "DEBUG"
    loggers = ["akka.event.slf4j.Slf4jLogger"]
    stdout-loglevel = OFF

    actor {
      provider = "akka.remote.RemoteActorRefProvider"
    }
    remote {
      enabled-transports = ["akka.remote.netty.tcp"]
      netty.tcp {
        hostname = "192.168.33.10"
        port = 0
      }
    }
}
 ```
 * Go to /vagrant/csw and run `./install.sh`. This should create /vagrant/install directory
 * Go to /vagrant/csw-pkg-demo and run `./install.sh`. 
 * Go to /vagrant/csw-play-demo and run `./install.sh`
 * To run the CSW demo, open one more terminal window and do `vagrant ssh`
  * In one of the terminal windows, go to /vagrant/install/bin
  * Run `./test_containers.sh`
  * In the other terminal window, go to /vagrant/install/bin
  * Run `./demowebserver`
  * In the browser, go to `http://192.168.33.10:9000`
    This should give you demo app page.
  * Select some filter and dispenser value and submit.
