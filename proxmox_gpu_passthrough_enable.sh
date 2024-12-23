#!/bin/bash
################################################################################
# Script de configuration IOMMU et GPU passthrough sur Proxmox
# 
# Ce script :
#  1. Détecte si le CPU est Intel ou AMD.
#  2. Met à jour /etc/default/grub avec les options IOMMU appropriées.
#  3. Ajoute les modules VFIO dans /etc/modules.
#  4. Blackliste les drivers graphiques dans /etc/modprobe.d/blacklist.conf.
#  5. Met à jour GRUB et l’initramfs.
#  6. Propose un redémarrage pour prendre en compte les changements.
#
# Version : 1.0
################################################################################

########################
#  CONFIGURATION / LOG #
########################

LOGFILE="/var/log/proxmox_gpu_setup.log"

# Rediriger la sortie standard et d'erreur vers le fichier LOG
exec > >(tee -a "$LOGFILE") 2>&1

echo "==========================================================="
echo "[INFO] Début du script de configuration GPU Passthrough"
echo "==========================================================="

########################
#  VERIFICATIONS DE BASE
########################

# 1. Vérifier si le script est exécuté en root
if [[ $EUID -ne 0 ]]; then
  echo "[ERREUR] Ce script doit être exécuté en tant que root (ou via sudo)."
  exit 1
fi

# 2. Vérifier la présence des fichiers critiques
if [[ ! -f /etc/default/grub ]]; then
  echo "[ERREUR] Fichier /etc/default/grub introuvable. Abandon."
  exit 1
fi

########################
#  DETECTION DU CPU
########################

echo "[INFO] Détection du type de CPU..."
CPU_TYPE=""
if grep -q "GenuineIntel" /proc/cpuinfo; then
  CPU_TYPE="intel"
  echo "[INFO] CPU Intel détecté."
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
  CPU_TYPE="amd"
  echo "[INFO] CPU AMD détecté."
else
  echo "[ERREUR] Type de CPU inconnu ou non supporté. Veuillez vérifier manuellement."
  exit 1
fi

# Définir l'option IOMMU correspondant au CPU détecté
if [[ "$CPU_TYPE" == "intel" ]]; then
  IOMMU_OPTION="intel_iommu=on iommu=pt"
elif [[ "$CPU_TYPE" == "amd" ]]; then
  IOMMU_OPTION="amd_iommu=on iommu=pt"
fi

##############################
#  MISE A JOUR DE /etc/default/grub
##############################

echo "[INFO] Mise à jour des options IOMMU dans /etc/default/grub..."

# On utilise sed pour insérer les options IOMMU dans la ligne GRUB_CMDLINE_LINUX_DEFAULT
# - Avant de le faire, on vérifie si l'option est déjà présente
if grep -q "$IOMMU_OPTION" /etc/default/grub; then
  echo "[INFO] Les options IOMMU sont déjà présentes dans /etc/default/grub."
else
  echo "[INFO] Insertion de '$IOMMU_OPTION' dans /etc/default/grub."
  sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"/\1 $IOMMU_OPTION\"/" /etc/default/grub
fi

##############################
#  AJOUT DES MODULES VFIO
##############################

echo "[INFO] Configuration de /etc/modules pour activer VFIO..."

# Liste des modules requis
VFIO_MODULES=("vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd")

for MODULE in "${VFIO_MODULES[@]}"; do
  if ! grep -q "^$MODULE" /etc/modules; then
    echo "[INFO] Ajout du module '$MODULE' à /etc/modules."
    echo "$MODULE" >> /etc/modules
  else
    echo "[INFO] Le module '$MODULE' est déjà présent dans /etc/modules."
  fi
done

##############################
#  BLACKLIST DES DRIVERS GPU
##############################

echo "[INFO] Blacklist des drivers GPU dans /etc/modprobe.d/blacklist.conf..."

BLACKLIST_FILE="/etc/modprobe.d/blacklist.conf"

# Liste des drivers à blacklister
DRIVERS_BLACKLIST=("nouveau" "nvidia" "radeon")

# Créer le fichier s'il n'existe pas
if [[ ! -f "$BLACKLIST_FILE" ]]; then
  touch "$BLACKLIST_FILE"
  echo "[INFO] Fichier $BLACKLIST_FILE créé."
fi

for DRIVER in "${DRIVERS_BLACKLIST[@]}"; do
  if ! grep -q "^blacklist $DRIVER" "$BLACKLIST_FILE"; then
    echo "[INFO] Blacklist du driver '$DRIVER'."
    echo "blacklist $DRIVER" >> "$BLACKLIST_FILE"
  else
    echo "[INFO] Le driver '$DRIVER' est déjà blacklisté."
  fi
done

##############################
#  MISE A JOUR DE GRUB & INITRAMFS
##############################

echo "[INFO] Mise à jour de GRUB..."
update-grub

echo "[INFO] Mise à jour de l’initramfs..."
update-initramfs -u

##############################
#  REDÉMARRAGE
##############################

echo ""
echo "==========================================================="
echo "[INFO] Configuration terminée avec succès."
echo "==========================================================="
echo "Un redémarrage est nécessaire pour appliquer les modifications."
read -p "Voulez-vous redémarrer maintenant ? [o/N] : " REPONSE

case "$REPONSE" in
  [oO]|[oO][uU][iI])
    echo "[INFO] Redémarrage en cours..."
    reboot
    ;;
  *)
    echo "[INFO] Redémarrage annulé. Pensez à redémarrer manuellement plus tard."
    ;;
esac

exit 0
