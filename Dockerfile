#from https://github.com/Amitie10g/docker-msys2/blob/master/Dockerfile

ARG VERSION=ltsc2022

# Use 21H2 version due previous Windows versions caused the building process hang.
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS download

# Download msys2
RUN	setx /M path "%PATH%;C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl" && \
	powershell -Command "curl.exe -L \
		$(Invoke-RestMethod -UseBasicParsing https://api.github.com/repos/msys2/msys2-installer/releases/latest | \
			Select -ExpandProperty "assets" | \
			Select -ExpandProperty "browser_download_url" | \
			Select-String -Pattern '.sfx.exe$').ToString() \
		--output C:\\windows\\temp\\msys2-base.exe" && \
	C:\\windows\\temp\\msys2-base.exe

RUN	bash -l -c "pacman -Syuu --needed --noconfirm --noprogressbar" && \
	bash -l -c "pacman -Syu --needed --noconfirm --noprogressbar" && \
	bash -l -c "rm -fr /C/Users/ContainerUser/* /var/cache/pacman/pkg/*"

FROM mcr.microsoft.com/windows/servercore:$VERSION

# Copy MSYS2 from downloader
COPY --from=download C:\\msys64 C:\\msys64

RUN setx /M path "%PATH%;C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl" && \
	mklink /J C:\\msys64\\home\\ContainerUser C:\\Users\\ContainerUser && \
	setx HOME "C:\msys64\home\ContainerUser"

WORKDIR C:\\msys64\\home\\ContainerUser\\
CMD ["bash", "-l"]
