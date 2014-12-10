package es.ua.dictionary.connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author javi
 */
public class ConnectionUtils {

    private Connection connection;
    private List<PreparedStatement> preparedStatements;
    private List<ResultSet> resultSets;

    public ConnectionUtils(Connection connection) {
        this.connection = connection;
        preparedStatements = new ArrayList<PreparedStatement>();
        resultSets = new ArrayList<ResultSet>();
    }

    public Connection getConnection() {
        return connection;
    }

    public PreparedStatement prepareStatement(String query) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement(query);
        preparedStatements.add(preparedStatement);
        return preparedStatement;
    }

    public PreparedStatement prepareStatementReturnKeys(String query) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS);
        preparedStatements.add(preparedStatement);
        return preparedStatement;
    }

    public ResultSet executeQuery(PreparedStatement preparedStatement) throws SQLException {
        ResultSet resultSet = preparedStatement.executeQuery();
        resultSets.add(resultSet);
        return resultSet;
    }

    public ResultSet getGeneratedKeys(PreparedStatement preparedStatement) throws SQLException {
        ResultSet resultSet = preparedStatement.getGeneratedKeys();
        resultSets.add(resultSet);
        return resultSet;
    }

    public void close() throws SQLException {
        while (!resultSets.isEmpty()) {
            ResultSet resultSet = resultSets.remove(0);
            if (!resultSet.isClosed()) {
                resultSet.close();
            }
        }
        resultSets.clear();
        while (!preparedStatements.isEmpty()) {
            PreparedStatement preparedStatement = preparedStatements.remove(0);
            if (!preparedStatement.isClosed()) {
                preparedStatement.clearBatch();
                preparedStatement.clearParameters();
                preparedStatement.close();
            }
        }
        preparedStatements.clear();
    }

    public static Connection openConnection(String host, String name, String port, String user, String password) throws SQLException {
        return DriverManager.getConnection("jdbc:mysql://" + host + ":" + port + "/" + (name == null ? "" : name) + "?useCursorFetch=true&dontTrackOpenResources=true", user, password);
    }
}
