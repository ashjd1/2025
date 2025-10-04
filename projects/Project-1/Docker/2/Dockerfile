FROM bitnami/dotnet-sdk:latest
RUN dotnet new console -o ashu
WORKDIR /app/ashu
COPY Program.cs .
#RUN mv Program.cs ashu

CMD ["/bin/sh", "-c", "dotnet build && dotnet run"]
#CMD ["/bin/sh", "-c", "dotnet build && dotnet run"]