#!/bin/bash

source activate r-bio
jupyterhub-singleuser --KernelRestarter.restart_limit=0