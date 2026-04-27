FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="Projet CICD - Catal-Log"
LABEL org.opencontainers.image.description="Image Nginx servant un site statique pour l'évaluation EC06"
LABEL org.opencontainers.image.source="https://github.com/TEST97440/TP-CICD"

COPY site/ /usr/share/nginx/html/
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 83
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -q -O - http://localhost:8083/ >/dev/null || exit 1
