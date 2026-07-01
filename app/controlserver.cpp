#include "controlserver.h"

ControlServer::ControlServer(QObject *parent)
    : QObject(parent)
{
    connect(&m_server, &QTcpServer::newConnection, this, &ControlServer::onNewConnection);
}

bool ControlServer::listen(quint16 port, const QHostAddress &address)
{
    if (m_server.isListening())
        return true;

    const bool ok = m_server.listen(address, port);
    if (ok)
        emit listeningChanged();
    return ok;
}

bool ControlServer::isListening() const
{
    return m_server.isListening();
}

void ControlServer::reply(const QString &text)
{
    if (!m_currentClient)
        return;

    m_currentClient->write(text.toUtf8());
    if (!text.endsWith(QLatin1Char('\n')))
        m_currentClient->write("\n");
}

void ControlServer::onNewConnection()
{
    while (QTcpSocket *client = m_server.nextPendingConnection()) {
        m_buffers.insert(client, QByteArray());
        connect(client, &QTcpSocket::readyRead, this, &ControlServer::onReadyRead);
        connect(client, &QTcpSocket::disconnected, this, &ControlServer::onDisconnected);
    }
}

void ControlServer::onReadyRead()
{
    QTcpSocket *client = qobject_cast<QTcpSocket *>(sender());
    if (!client)
        return;

    QByteArray &buffer = m_buffers[client];
    buffer.append(client->readAll());

    // Process every complete line; keep any partial remainder buffered.
    int newlineIndex;
    while ((newlineIndex = buffer.indexOf('\n')) != -1) {
        const QByteArray rawLine = buffer.left(newlineIndex);
        buffer.remove(0, newlineIndex + 1);

        const QString line = QString::fromUtf8(rawLine).trimmed();
        if (line.isEmpty())
            continue;

        // Emitted synchronously: reply() targets this client for the duration.
        m_currentClient = client;
        emit commandReceived(line);
        m_currentClient = nullptr;
    }
}

void ControlServer::onDisconnected()
{
    QTcpSocket *client = qobject_cast<QTcpSocket *>(sender());
    if (!client)
        return;

    m_buffers.remove(client);
    if (m_currentClient == client)
        m_currentClient = nullptr;
    client->deleteLater();
}
