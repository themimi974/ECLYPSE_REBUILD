# **Eclypse Rebuild - Automatisation de VDI sur Proxmox**

## **Description du Projet**

Le projet **Eclypse Rebuild** vise à simplifier et automatiser la mise en place d’infrastructures de bureau virtuel (VDI) sur Proxmox. Grâce à des scripts dédiés, il standardise la configuration des environnements, incluant :

- **Passthrough GPU** : pour des performances graphiques avancées.
- **Machines Virtuelles Windows** : avec une configuration optimisée pour les environnements VDI.
- **Déploiement de pilotes et outils** : tels qu’un pilote d’écran virtuel et un pilote audio (VB-Cable).

Ce projet s’adresse aux administrateurs systèmes souhaitant réduire la complexité des déploiements tout en offrant une infrastructure performante et prête pour l'usage final.

---

## **Fonctionnalités**

### **1. Configuration IOMMU et GPU Passthrough**
Un script dédié simplifie la configuration requise pour le passthrough GPU en Proxmox, notamment :

- Détection automatique du type de CPU (Intel ou AMD) et activation des options IOMMU correspondantes.
- Chargement des modules VFIO nécessaires.
- Blacklist des pilotes graphiques incompatibles.
- Mise à jour de GRUB et de l’initramfs.
- Proposition de redémarrage pour finaliser la configuration.

### **2. Automatisation des Machines Virtuelles Windows**
Un script configure automatiquement les VMs Windows avec les fonctionnalités suivantes :

- **Installation automatisée** : création rapide de VMs Windows adaptées aux environnements VDI.
- **Installation de pilotes spécifiques** :
  - Pilote d’écran virtuel (basé sur un fork disponible dans votre dépôt).
  - Pilote audio VB-Cable pour la redirection audio des sessions distantes.
- **Optimisations GPU** : configuration pour des performances graphiques optimales en passthrough.
- **Configuration matérielle standardisée** : automatisation des paramètres de base tels que la RAM, les cœurs CPU, et le disque.
- **Déploiement répétable** : permet de standardiser les VMs grâce à un processus homogène.

### **3. Paramétrage des Machines**
Le script prend également en charge :

- La création d'utilisateurs simples pour les besoins des sessions.
- La configuration des paramètres réseau.
- Les personnalisations Windows nécessaires pour une expérience utilisateur fluide.

### **4. Déploiement de Sunshine**
Sunshine, un outil de streaming à distance léger, est déployé automatiquement :

- Installation et configuration de Sunshine sur chaque VM Windows.
- Intégration des pilotes et des optimisations pour un streaming performant.
- Préparation des machines pour un accès distant transparent.

### **5. Déploiement Basé sur Templates**
**(Fonctionnalité à venir)**  
Les mises à jour futures incluront :

- La création de templates pour standardiser les déploiements de VMs.
- Un processus de déploiement entièrement automatisé à partir de ces templates à l'aide d'un micro logiciel (prochainement).

---

### Remerciements

Une partie importante des connaissances utilisées pour ce projet **Eclypse** provient des vidéos et tutoriels de **Linus Tech Tips (LTT)**, de **Craft Computing (Jeff)** et de **Tim de la chaine Technotim**. Un grand merci à eux pour leurs contenus clairs et instructifs sur Proxmox, le GPU passthrough et la virtualisation, sans lesquels ce projet n’aurait pas vu le jour.
