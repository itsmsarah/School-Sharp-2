<%@page import ="java.sql.Connection" %>
<%@page import ="java.sql.DriverManager" %>
<%@page import = "java.sql.*" %>
<%@page import = "java.sql.ResultSet" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Listagem Funcionários</title>
        <link rel="stylesheet" href="./style-listagem_func.css">    
        <link rel="Icon" href="./images/Icon-tab.svg">
    </head>
    <body>
        <main>
            <div class="logo-container">
                <img src="./images/Logo-Senai-AutoPark.svg" alt="">
                <h1>Listagem de funcionários</h1>
            </div>
            <% 
            try {
                // Fazer conexão com o banco de dados
                Connection conecta;
                PreparedStatement st;
                Class.forName("com.mysql.cj.jdbc.Driver");
                String url = "jdbc:mysql://localhost:3306/senai_autopark2";

                String user = "root";
                String password = "root";

                conecta = DriverManager.getConnection(url, user, password);

                // Lista os dados da tabela funcionarios
                String sql = "SELECT * FROM funcionarios";
                st = conecta.prepareStatement(sql);
                ResultSet rs = st.executeQuery();
            %>
            
            <div class="listar-container">
                <table class="listar-box">
                    <tr>
                        <th>Nome</th>
                        <th>Usuario</th>
                        <th>E-mail</th>
                        <th>Senha</th>
                        <th>Cargo</th>
                    </tr>

                    <%
                    while (rs.next()) {
                    %>
                    <tr class="table-container">
                        <td><%=rs.getString("nome_func")%></td>
                        <td><%=rs.getString("usuario")%></td>
                        <td><%=rs.getString("email")%></td>
                        <td><%=rs.getString("senha")%></td>
                        <td><%=rs.getString("cargo")%></td>
                    </tr>
                    <%
                    }
                    %>
                </table>
            </div>
            
            <div class="button-container">
                <a href="configuracoes_sistema.html">Voltar</a>
            </div>
            
            <%
            } catch (Exception e) {
                out.println("Erro: " + e.getMessage());
                e.printStackTrace(); // Adicionado para visualizar erros no console do servidor
            }
            %>
        </main>
    </body>
</html>

