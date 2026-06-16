# PoisonPipe

This is a project repository for the course EP284U - Ethical Hacking. The demo shows an example vector of an attack aimed towards a CICD-pipeline where credentials necessary for pushing code to the pipeline have been leaked. Making it possible to insert malicious code into the pipeline and having it deployed to the simulated live environment.

---

## Features

- **Built around docker compose** – The entire project is built around a single docker-compose file and docker is therefore the only dependency for running this project
- **Purpose built containers** - The containers used for the docker setup are based around the alpine and debian base containers and are purpose built for this setup. Making them lightweight and making the process of running the setup fast.
- **Reports on the weakness** - In the [/docs] directory you can find pdfs and their corresponding source .tex files where I explain the exploit, the process of building it and also the initial proposal i wrote for the project. The final report also includes a walkthrough of the exploit and its different stages mapped to the [Cyber Kill Chain](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html).

---

## Quick Start

### Dependencies

- Docker and docker-compose
- A computer **NOT** on the 10.10.10.0/24 network (You can also simply change the network in the [docker-compose.yml] file if this is a problem)
- (Internet connection)

### Installations

**Clone (or copy) the repository**

**Enter the repository**
```bash
cd PoisonPipe
```

**Run the demo**
```bash
docker compose up -d
```

**Stopping and cleaning up after running the demo**
```bash
docker compose down --rmi all
```

## Try it yourself

Make sure to run the setup using the commands above for running the demo. After this you can try to find and use the exploit yourself.

### Constraints to follow as an Attacker

To make sure that only the intended exploit is used there are some constraints. As running it locally will make it so that you might have access to more information than a typical attacker would have. You might also know of other exploits aimed at different services than was intended. (You of course don't have to listen to these contraints but for the demo to showcase the intended weakness it is recommended.) 

The constraints are as follows:
1. You may not read the repository to find clues as to how to solve the problem. All the information necessary is given either in this repo or in the environment
2. You may not access the containers using the docker deamon. This includes checking logs or running an interactive shell.
3. You may not attack the services in the containers with exploits. You will have access to credentials that will allow you to access the services you need and no CVEs have to be used in the challenge
4. You will not have access to the flag-holder machine through any other way than by going through the cicd-pipeline on the deploy machine. Any other way you may find in is **NOT INTENDED**

### Where to begin

With the contraints out of the way these are 2 pieces of information you need to start. 

1. The IP address 10.10.10.2 might have something interesting on it
2. You can find some credentials that might come in handy in the [/leaked-credentials.md]

## Repository Structure
```
/ PoisonPipe
├── / containers                  # The context for the docker containers build process
│   ├── / deploy                  # Setup for the Gitea server and the "deploy server" of the CICD pipeline
│   │   ├── / config              # Configuration for the Gitea server
│   │   ├── / git-repo            # The two different git repos that will be on the gitea server and that the attacker will exploit
│   │   │   ├── / development
│   │   │   └── / production
│   │   ├── / scripts             # Scripts that the docker container uses. Including its entrypoint and the deploy script
│   │   └── Dockerfile
│   ├── / flag-holder             # Setup for the "flag-holder" server. Including the actual flag
│   └── / shared                  # A shared ssh key used for the deployment. Used by the deploy server to run ansible over ssh
├── / docs
│   ├── / sources                 # The sources for the pdfs including the .tex files and the references used
│   └── project-proposal.pdf    # The project-proposal for the demo and the project as a whole
├── docker-compose.yml          # The main docker compose file
├── leaked-credentials.md       # A small file containing the credentials needed to run the exploit
├── LICENCE
└── README.md
```
