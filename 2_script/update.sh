#===========================================================================
#-- Author  : kido
#-- Name    : update.sh (update submodule)
#-- History : ver.1.00 (26/10/20) 1st release 
#--         :
#===========================================================================
#!/bin/bash

cd ..

git submodule update --remote
cd 3_third_party/VLSI_COMMON
git sparse-checkout init --cone
git sparse-checkout set 01_uvm_env/apb_mst_env
