-----------------------------------------------------------------------------
-- Doanload Pool 
--
local DownloadPool = class('DownloadPool')

function DownloadPool:ctor()
    self.pool = {}
    self.isDownloading = false
end

function DownloadPool:raise()
    if self.poolListenId then 
        return 
    end
    self.poolListenId = util:scheduleFunc(handler(self, self.fetch), 1, false)
end

function DownloadPool:close()
    if not self.poolListenId then 
        return 
    end
    util:unscheduleFunc(self.poolListenId)
    self.poolListenId = nil
    self.isDownloading = false
end

function DownloadPool:dumpQueue()
    _print('当前下载队列：')
    for i,v in ipairs(self.pool) do
        _print(string.format("  [%d] name:%s, id:%d", i, v.resName, v.idx))
    end
end

function DownloadPool:push(resName, idx)
    for _,v in ipairs(self.pool) do
        if v.resName == resName and v.idx == idx then
            _print("已经加入下载队列，无需再次添加: ", resName, idx)
            self:dumpQueue()
            return false
        end
    end
    table.insert(self.pool, {resName=resName, idx=idx})
    self:raise()
    self:dumpQueue()
    return true
end

function DownloadPool:pop(resName)
    if not resName then return end
    if #self.pool == 0 then 
        return 
    end
    for i,v in ipairs(self.pool) do
        if resName == v.resName then
            table.remove(self.pool, i)
            self.isDownloading = false
            _print("从下载队列移除任务: ", v.resName, v.idx, i)
            break
        end
    end
end

function DownloadPool:fetch()
    if #self.pool == 0 then
        _print("下载队列为空，关闭下载监听")
        self:close()
        return
    end
    if self.isDownloading then
        return
    end
    local one = self.pool[1]
    self.isDownloading = downloadExtendRes(one.resName, one.idx)
    _print("从下载队列获取任务: ", one.resName, one.idx)
    self:dumpQueue()
end

function DownloadPool:getState()
    return self.isDownloading
end

return DownloadPool
