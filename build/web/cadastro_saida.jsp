<%@page import ="java.sql.Connection"%>
<%@page import ="java.sql.DriverManager"%>
<%@page import ="java.sql.PreparedStatement"%>
<%@page import="java.time.*" %>
<%@page import="java.sql.ResultSet" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Cadastro de Saída de Veículo</title>
        <link rel="stylesheet" href="./style-saida.css"> 
    </head>
    <body>
       

   <%
    // Captura os dados do formulário ( o forms está aqui nessa page, pois resolvemos integrar em um só
    String placa = request.getParameter("placa");
    String formaPagamento = request.getParameter("forma_pagamento");

    try {
        // Conexão com o banco de dados
        Connection conecta;
        PreparedStatement st;
        ResultSet rs;
        Class.forName("com.mysql.cj.jdbc.Driver");

        String url = "jdbc:mysql://localhost:3306/senai_autopark2";
        String user = "root";
        String password = "root";

        conecta = DriverManager.getConnection(url, user, password);

        // Buscar a data, horário de entrada e vaga do veículo
        //data_entrada, horario_entrada, vagasid
        String sqlBusca = "SELECT * FROM carros WHERE placa = ? AND data_saida IS NULL";
        st = conecta.prepareStatement(sqlBusca);
        st.setString(1, placa);
        rs = st.executeQuery();

        if (rs.next()) {
            // Obtendo dados do carro
            java.sql.Date dataEntrada = rs.getDate("data_entrada"); // transforma em objeto, ou seja, conterá apenas a parte da data (ano, mês e dia) sem incluir o horário.
            java.sql.Time horarioEntrada = rs.getTime("horario_entrada");// e aqui ao contrario, contém só o horário
            int vagasId = rs.getInt("vagasid"); // Pegando o ID da vaga usada

            // Convertendo para LocalDateTime para cálculo correto
            LocalDateTime entrada = LocalDateTime.of(dataEntrada.toLocalDate(), horarioEntrada.toLocalTime());//Junta as duas  primeiras informações e criamos um LocalDateTime, que contém data e hora completas.
            LocalDateTime saida = LocalDateTime.now(); // Obtendo a saída atual

            // Calculando tempo de permanência corretamente
            Duration duracao = Duration.between(entrada, saida);
            long minutos = duracao.toMinutes(); // Pegamos a diferença em minutos
            long horas = minutos / 60; // aqui converte para horas completas

            // Hora de realizar a cobrança
            
            //Pegando o valor do preço por hora e preço por hora adicional do banco de dados para realizar o cálculo
            String sqlPrecos = "SELECT preco_hora, preco_hora_adicional FROM sistema";
            st = conecta.prepareStatement(sqlPrecos);
            rs = st.executeQuery();
            
            double preco_hora = 0;
            double preco_hora_adicional = 0;

            if (rs.next()) {
                preco_hora = rs.getDouble("preco_hora");
                preco_hora_adicional = rs.getDouble("preco_hora_adicional");
            }
            
           //Calculando o valor total do pagamento
            double valorTotal;
            if (horas <= 1) {
                valorTotal = preco_hora; 
            } else {
                valorTotal = preco_hora + ((horas - 1) * preco_hora_adicional);
            }

            // Atualizando a saída do veículo no banco de dados
            String sqlAtualiza = "UPDATE carros SET data_saida = CURRENT_DATE, horario_saida = CURRENT_TIME, valor_total = ?, forma_pagamento = ? WHERE placa = ?";
            st = conecta.prepareStatement(sqlAtualiza);
            st.setDouble(1,valorTotal);
            st.setString(2, formaPagamento);
            st.setString(3, placa);
            st.executeUpdate();

            // Atualizar status da vaga para disponível
            String sqlVaga = "UPDATE vagas SET vaga_status = 'Disponível' WHERE vagasid = ?";
            st = conecta.prepareStatement(sqlVaga);
            st.setInt(1, vagasId);
            st.executeUpdate();

            // Exibir informações ao usuário
            %>
            
            <div class="cobranca-container">
                <h2>Veículo de placa: <%=placa%> </h2>

                <div class="preco-box">
                    <h3>Preço Total</h3>
                    <h4>R$ <%=valorTotal%></h4>
                    <div class="date-box">
                       <div class="date-card">
                            <div class="date-text">
                                <p>Hora de Entrada</p>
                                <div class="hour-box">
                                    <p> <%=dataEntrada%> </p>
                                    <p> <%=horarioEntrada%> </p>
                                </div>
                            </div>
                            <img src="./images/solar_calendar-line-duotone.svg" alt="">
                       </div> 

                       <div class="date-card">
                            <div class="date-text">
                                <p>Hora de Saida</p>
                                <div class="hour-box">
                                    <p><%=LocalDate.now()%></p>
                                    <p><%=LocalTime.now()%></p>
                                </div>
                            </div>
                            <img src="./images/material-symbols-light_departure-board-outline.svg" alt="">
                        </div>  
                   </div>                    
                </div>
            
            <div class="pagamento-box">
                    <div class="pagamento-button">
                        <a href="">Dinheiro</a>
                    </div>
                    <div class="pagamento-button">
                        <a href="">Cartão Débito</a>
                    </div>
            </div>
            
            <%
        } else {
            out.print("<p style='color:red;'>Veículo não está cadastrado ou já saiu.</p>");
        }

        // Fechar conexão
        conecta.close();
    } catch (Exception x) {
        out.print("<p style='color:red;'>Erro: " + x.getMessage() + "</p>");
    }
%>



    </body>
</html>