FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS final

# Install Visual C++ Redistributable for Visual Studio 2017
# https://download.visualstudio.microsoft.com/download/pr/d0b808a8-aa78-4250-8e54-49b8c23f7328/9c5e6532055786367ee61aafb3313c95/vc_redist.x86.exe
COPY docker/Binaries/vc_redist.x86.exe /temp/vc_redist.x86.exe
RUN C:\temp\vc_redist.x86.exe /quiet /norestart /wait

COPY Configs /PEA/Configs
WORKDIR /app
COPY Service/bin/Release .

ENTRYPOINT ["Service.exe"]
