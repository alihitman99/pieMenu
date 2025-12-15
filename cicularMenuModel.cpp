#include "cicularMenuModel.h"

CicularMenuModel::CicularMenuModel(QObject *parent)
    : QAbstractListModel{parent}
{}

int CicularMenuModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return m_items.size();
}

QVariant CicularMenuModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_items.size())
        return {};

    const auto& item = m_items[index.row()];
    switch (role) {
    case LabelRole: return item.label;
    case ValueRole: return item.value;
    case ColorRole: return item.color;
    case IconRole: return item.icon;
    }
    return {};
}

QHash<int, QByteArray> CicularMenuModel::roleNames() const {
    return {
        { LabelRole, "label" },
        { ColorRole, "color" },
        { ValueRole, "value" },
        { IconRole, "icon" }
    };
}

void CicularMenuModel::addItem(const QString &label, double value, const QString &color, const QString &icon) {
    beginInsertRows(QModelIndex(), m_items.size(), m_items.size());
    m_items.push_back({ label, color, value, icon });
    endInsertRows();
}

void CicularMenuModel::cicularClicked(const QString &label)
{
    qDebug() << label;
}
