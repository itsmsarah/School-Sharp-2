<%@page import ="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login</title>
    </head>
    <body>
        
        
<%
    
    // aqui pega os dados dos forms do index.html
    String usuario = request.getParameter("usuario");
    String senha = request.getParameter("senha");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        String url = "jdbc:mysql://localhost:3306/senai_autopark2?useUnicode=true&characterEncoding=UTF-8";
        String user = "root";
        String password = "root";

        Connection conecta = DriverManager.getConnection(url, user, password);

        String sql = "SELECT cargo FROM funcionarios WHERE usuario = ? AND senha = ?";
        PreparedStatement st = conecta.prepareStatement(sql);
        st.setString(1, usuario);
        st.setString(2, senha);

        ResultSet rs = st.executeQuery();

        if (rs.next()) {
            String cargo_banco = rs.getString("cargo");
            if (cargo_banco.equals("admin")) {
                response.sendRedirect("menu_admin.html");
            } else {
                response.sendRedirect("menu_operador.html");
            }
        } else {
            response.sendRedirect("menu_operador.html");
        }

        rs.close();
        st.close();
        conecta.close();

    } catch (Exception x) {
         response.sendRedirect("error.html");

        out.println("Erro: " + x.getMessage());
        x.printStackTrace(new java.io.PrintWriter(out));
    }
%>
    </body>
</html>
