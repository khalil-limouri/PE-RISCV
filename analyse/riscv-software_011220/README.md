# RISCV

Le projet contient la description VHDL du RV32I (adressage: 32 bits / jeu d'instructions 32 bits de base (I)). 
Le répertoire "RV32I_Monocycle" contient une architecture monocycle telle que décrite dans le livre d'Hennessy et Patterson "Computer Organization and Design, Edition RISCV" à la page 260 (chapter 4). Les schémas des entités RV32I_Monocycle_Controlpath et RV32I_Monocycle_datapath sont décrits dans le répertoire ./RV32I_Monocycle/images. Les instructions CSR, ENV et FENCE ne sont pas supportées.

La spécification de l'ISA pour le RISC-V est donnée à l'adresse : https://riscv.org/specifications/


# Installation de la chaine de cross compilation

La compilation de code C pour le processeur RISC-V peut-être effectué à l'aide
de la "GNU toolchain for RISC-V including GCC". Source disponibles à partir du
clone <https://github.com/riscv/riscv-gnu-toolchain>. Ou la version déjà
compilée à partir de la version SiFive de gcc disponible ici:
<https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/>

Préparation de la chaine de cross compilation binaire sur un linux 64 bits
(validé sur vienne et quebec):

~~~
wget "https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/download/v8.3.0-1.1/xpack-riscv-none-embed-gcc-8.3.0-1.1-linux-x64.tgz"
tar -xzf xpack-riscv-none-embed-gcc-8.3.0-1.1-linux-x64.tgz
mv xPacks crosscompile
export PATH="$(readlink -f crosscompile/riscv-none-embed-gcc/8.3.0-1.1/bin/):$PATH"
~~~


