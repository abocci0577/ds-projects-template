# Data Science template repository for new projects

Repository containing scaffolding for a data science project. It contains:
* Directory structure for the project
* Necessary files to set up dedicated conda environment
* (Basic) necessary files to use the project (including the dedicated conda environment) within docker 


### Project organization

Project organization is based on ideas from [_Good Enough Practices for Scientific Computing_](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005510).

1. Put each project in its own directory, which is named after the project.
2. Put external scripts or compiled programs in the `bin` directory.
3. Put raw data and metadata in a `data` directory.
4. Put text documents associated with the project in the `doc` directory.
5. Put all Docker related files in the `docker` directory.
6. Install the Conda environment into an `env` directory. 
7. Put all notebooks in the `notebooks` directory.
8. Put files generated during cleanup and analysis in a `results` directory.
9. Put project source code in the `src` directory.
10. Name all files to reflect their content or function.



## Creating a new project from this template

**Option 1**:
Simply follow the [instructions](https://help.github.com/en/articles/creating-a-repository-from-a-template) to create a new project repository from this template.

**Option 2 (manually):**

In a terminal:
```
# The name of your project
PROJECT_NAME=ds-project-name 

## this repo
TEMPLATE_NAME=ds-projects-template
TEMPLATE_REPO=git@github.com:abocci0577/ds-projects-template.git

##
git clone $TEMPLATE_REPO
mv $TEMPLATE_NAME $PROJECT_NAME
cd $PROJECT_NAME
rm -rf .git ## stop here if you don't want the project in git

## attach to git (optional)
## - First create a new repo (i.e. called with same name of the project) in your GitHub account
## - Don't initialize it with a README, .gitignore, or license.
REPO_NAME=$PROJECT_NAME   # REPO_NAME and PROJECT_NAME can be different
GITHUB_USER=abocci0577    # your Github username

git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:$GITHUB_USER/$REPO_NAME
git push -u --force origin master
```

**NOTE**: If you don't need the project to be _git-aware_, just stop at the  `rm -rf .git*` stage. It will detach the directory from Git and will be purely local.



## Changelog 


#### .gitignore

Everything was removed ( [original version here](https://github.com/kaust-vislab/python-data-science-project/blob/master/.gitignore))

What I  keep there:
* the data/ part (optional)
* the `/env` that will be created at the initialization of conda. The name will be always `/env`. The prefix will include the full path, so there won't be confusion (`<somepath>/<project-name>/env`)
* extra files generated by jupyter (may need fine tuning)
* for any other library you may run (for instance Flask), it has to be checked what extra generated files need to be ignored


#### How many enviroments?

In the end I've decided to use one conda env for each project:
* One project, one directory structure, one conda env, one repo. Simple.
    * for portability and reproducibiliy better to have one project  per repository, with its own enviroment
* Outside Docker (locally) the conda env is here not in the miniconda `envs/` directory
    * careful! a lot of files! in particular if you sync the directory with could services (One Drive, Dropbox, etc..)
    *  Jupyter should be run from the `base` environment (outside this repo), such that only one jupyter is used for all projects. Kernels/environments can be changed within Jupyter. This avoid messing with jupyter extension installations, jupyter tmp files in .gitignore, etc.. 
    * also you still need`ipkernel` installed in this repo
* If Docker is used as PaaS, better to have one image per project, and therefore one env per project
* If used with Docker to run Jupyter (or other servers), maybe to run remotely (AWS, etc..), still all can be put in one conda env. It needs some tuning for jupyter files and data files.
    * a special use case is to run the _same_ project with different kernels, i.e. testing different versions of libraries. Then you need multiple envs

**NOTE**: current template for Dockerfile will create only 1 conda env

## Using Conda

### Creating the Conda environment

**NOTE**: this assumes you have _miniconda_ or _anaconda_ already installed (if you run Docker will do that)

After adding any necessary dependencies for your project to the Conda `environment.yml` file you can create the environment in a sub-directory of your project directory by running the following command.

```bash
ENV_PREFIX=$PWD/env
conda env create --prefix $ENV_PREFIX --file environment.yml --force
```

If you need to install something from `pip` (check if in conda channels first, _pip_ should be your last resource), put it in a `requirement.txt`. 
Instead to run manually (`pip install -r requirement.txt`), do it within `environment.yml` (it can run `pip` with any given flag)

```bash
    dependencies:
      - <other packages>
      - channel::package=X,Y,Z    ## for a package from a specific channel			
      - pip:
        - -r file:requirement.txt
```


Once the new environment has been created you can activate the environment with the following 
command.

```bash
conda activate $ENV_PREFIX
```

Note that the `ENV_PREFIX` directory is *not* under version control as it can always be re-created as necessary.

If you wish to have the kernel for this envinroment in a JupyterLab instance from a Jupyter server in `base`, you need to add it with:
```bash
## put the kernel in the right place
ipython kernel install --user --name=$PROJECT_NAME
```

This is already in `postBuild` so just do:
```bash
conda activate $ENV_PREFIX # optional if environment already active
. postBuild
```

For your convenience these commands have been combined in a shell script `./bin/create-conda-env.sh`. 
Sourcing the shell script will create the Conda environment, activate the Conda environment, and build 
JupyterLab with any additional extensions. The script should be run from the project root directory as 
follows. 

```bash
## it needs to be source to activate the new enviroment on the current shell. A simple execution of the file will not work
> . ./bin/create-conda-env.sh

## Check if the environment variable is set
> echo $ENV_PREFIX
/Users/boccia/work/testgit/ds-projects-template/env
```

### Listing the full contents of the Conda environment

The list of explicit dependencies for the project are listed in the `environment.yml` file. To see 
the full lost of packages installed into the environment run the following command.

```bash
conda list --prefix $ENV_PREFIX
```

### Updating the Conda environment

**Best practice instead of run manually `conda install` or `pip requirement.txt`

If you add (remove) dependencies to (from) the `environment.yml` file or the `requirements.txt` file 
after the environment has already been created, then you can re-create the environment with the 
following command.

```bash
## update (prune will remove obsolete dependences)

$ conda env update --prefix ./env --file environment.yml  --prune
$ conda env update --prefix $ENV_PREFIX  --file environment.yml  --prune

$ conda env create --prefix $ENV_PREFIX --file environment.yml --force


```

## Using Docker

In order to build Docker images for your project and run containers you will need to install 
[Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).

Detailed instructions for using Docker to build and image and launch containers can be found in 
the `docker/README.md`.
