FROM nginx:alpine
# On copie le fichier local dans le dossier par défaut de Nginx
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80