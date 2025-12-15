#ifndef CICULARMENUMODEL_H
#define CICULARMENUMODEL_H

#include <QAbstractListModel>
#include <QObject>

struct CicularItem{
    QString label;
    QString color;
    double value;
    QString icon;
};

class CicularMenuModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        LabelRole = Qt::UserRole + 1,
        ColorRole,
        ValueRole,
        IconRole
    };

    explicit CicularMenuModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role) const override;

    QHash<int, QByteArray> roleNames() const override;

    void addItem(const QString& label, double value, const QString& color, const QString& icon);
    Q_INVOKABLE void cicularClicked(const QString &label);

private:
    QVector<CicularItem> m_items;
};

#endif // CICULARMENUMODEL_H
