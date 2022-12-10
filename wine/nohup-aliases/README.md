## nohup

Nohup allows us to run the halo server console in the background without closing halo. We can also use a file named "input.txt" for example


to send commands to a halo console or even multiple halo consoles at once! Or just getting back control of the terminal from halo.


This can be especially useful for running multiple halo servers using wine without the use of screen, tmux, docker, and so on.



Example nohup setup for halo:


    cd
    touch input.txt
    echo "nohup tail -F ~/input.txt 2> /dev/null | nohup wineconsole haloceded.exe -path . &" > halopull/start-nohup.sh
    chmod +x halopull/start-nohup.sh


Then to start the halo server:

    cd halopull
    ./start-nohup.sh


The halo server will be sent to the background giving back control of stdin to our shell.


The halo console output can be viewed by doing:

    cat nohup.out


You can follow it by doing:


    tail -f nohup.out


Commands can be send to the halo server(s) like so:


    echo "no_lead 1" >> ~/input.txt


One nuance is halo commands that require quotes, for example:


    sv_say "this is a test"


must be done like this:


    echo "sv_say \"this is a test\"" >> ~/input.txt


Using bash aliases we can make this easier to do halo commands



## Bash aliases!


Instead of having to do this:


echo "no_lead 1" >> ~/input.txt


we can make this easier to do halo commands :)


Example bashrc setup:


    cd
    nano .bashrc

then copy and paste this into the bottom of the file and close + save:


    halo() {
        echo "$*" >> ~/input.txt
    }


finally:

    source .bashrc


then halo commands can be run like so:


    halo sv_players


## Side Notes:

Each halo console can have its own input file as well, or any combination of sharing input files :)


Another use is being able to grep for strings in the halo console. So by enabling chat echo in the halo console:


    halo chat_console_echo 1


You can tail nohup.out for cheat complaints for example:


    tail -f halopull/nohup.out | grep wall



This could be used to send alerts but there are issues with messages repeating after a while. 


nohup.out will continue to grow for as long as the halo console is running. 


Eventually this would require some sort of management if the halo server is left running long-term. Unfortunately, deleting nohup.out will


cause the halo console output to be gone. 


On ther hand one could send the output to /dev/null if they are used to this enviroment. 



## Webpage halo console logs

You can have the halo console be viewable on a webpage, for example to monitor chat like in the tail example above. You'd want to have the webpage behind a firewall. But here's an example using socat:


    while true; do socat -v -v TCP-LISTEN:9000,crlf,reuseaddr,fork SYSTEM:"echo HTTP/1.0 200; echo Content-Type\: text/plain; echo; tail -50 nohup.out" 2>/dev/null; sleep 1; done


Then in a browser visit the ip of your server on port 9000 (or whatever port you specify in the socat command). Here's an example address:


    http://45.56.67.78:9000/


You could could view this from phone. You could grep for different things to run multiple socats for. In Windows you enable WSL2 in Programs and Features (if it has hyper-v) and curl the logs in that. There are many different ways you can set this up :)

Here's an example curl loop to keep pulling the webpage:

    while sleep 5; do curl -v http://45.56.67.78:9000/ 2>/dev/null; done > scrape.txt


And then you can tail scrape.txt locally any ways you want :)