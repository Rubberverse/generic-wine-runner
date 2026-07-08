FROM    public.ecr.aws/docker/library/debian:trixie-slim AS base

ARG     CONT_USER=wine-runner \
        CONT_GROUP=wine-runner \
        CONT_UID=1100 \
        CONT_GID=1100 \
        DEBIAN_FRONTEND=noninteractive

ENV     WINEDEBUG=-all \
        WINEPREFIX=/srv/.wine \
        XDG_RUNTIME_DIR=/tmp

RUN apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends gpg curl wget ca-certificates bash tini \
    && dpkg --add-architecture i386 \
    && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources \
    && apt update \
    && apt install --no-install-recommends -y winehq-stable cabextract p7zip-full \
    && curl -L https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -o /usr/local/bin/winetricks \
    && chmod 555 /usr/local/bin/winetricks \
    && addgroup \
        --system \
        --gid "${CONT_GID}" \
        "${CONT_GROUP}" \
    && adduser \
        --home "/srv" \
        --shell "/sbin/false" \
        --uid ${CONT_UID} \
        --ingroup ${CONT_GROUP} \
        --disabled-password \
        ${CONT_USER} \
    && chown wine-runner:wine-runner /srv

USER    wine-runner:wine-runner
WORKDIR /srv/app

RUN wine reg add "HKCU\Software\Wine\Drivers" /v Graphics /t REG_SZ /d "null" /f >/dev/null 2>&1 \
    && wineserver -w \
    && WINEPREFIX=/srv/.wine winetricks --unattended --optout --no-isolate alldlls=builtin nocrashdialog sound=disabled win11 vd=off autostart_winedbg=disabled \
    && WINEPREFIX=/srv/.wine winetricks --unattended --optout --no-isolate crypt32 \
    && WINEPREFIX=/srv/.wine winetricks --unattended --optout --no-isolate mfc100 mfc110 mfc120 mfc140 mfc90 mfc80 mfc71 mfc70 mfc42 mfc40 msvcirt msvcrt40 vcrun2026 \
    && rm -rf /srv/.cache

USER    root
COPY    --chmod=555 entrypoint.sh /srv/entrypoint.sh

RUN apt remove -y p7zip-full cabextract gpg curl ca-certificates \
    && apt autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm /usr/local/bin/winetricks

USER    wine-runner:wine-runner
ENTRYPOINT ["tini", "--", "/srv/entrypoint.sh"]
